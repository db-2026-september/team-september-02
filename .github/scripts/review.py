import os
import sys
import base64
import re
from pathlib import Path
import anthropic
import requests

# ── Config ────────────────────────────────────────────────────────────────────
ANTHROPIC_API_KEY = os.environ["ANTHROPIC_API_KEY"]
GITHUB_TOKEN      = os.environ["GITHUB_TOKEN"]
REPO              = os.environ.get("REPO", "")
PR_NUMBER         = os.environ.get("PR_NUMBER", "")
COMMIT_SHA        = os.environ.get("COMMIT_SHA", "")

client = anthropic.Anthropic(api_key=ANTHROPIC_API_KEY)

# Відповідність ключів до реальних папок
LABS = {
    "lab1": "topic-03-database_design",
    "lab2": "topic-04-ddl",
    "lab3": "topic-09-dml",
    "lab4": "topic-10-views",
    "lab5": "topic-11-database-administration",
    "lab6": "topic-12-topic-functions-stored-procedures",
}

IMAGE_EXTS = {".png", ".jpg", ".jpeg", ".gif", ".webp"}
PDF_EXT    = ".pdf"
TEXT_EXTS  = {".sql", ".md", ".txt", ".ddl", ".dml", ".dbml"}

# ── GitHub helpers ─────────────────────────────────────────────────────────────
def post_pr_comment(body: str):
    if not PR_NUMBER:
        print("[skip] No PR_NUMBER — stdout:\n", body)
        return
    url = f"https://api.github.com/repos/{REPO}/issues/{PR_NUMBER}/comments"
    resp = requests.post(
        url,
        headers={"Authorization": f"Bearer {GITHUB_TOKEN}", "Accept": "application/vnd.github+json"},
        json={"body": body},
    )
    resp.raise_for_status()

def post_commit_comment(body: str):
    if not COMMIT_SHA:
        print("[skip] No COMMIT_SHA — stdout:\n", body)
        return
    url = f"https://api.github.com/repos/{REPO}/commits/{COMMIT_SHA}/comments"
    resp = requests.post(
        url,
        headers={"Authorization": f"Bearer {GITHUB_TOKEN}", "Accept": "application/vnd.github+json"},
        json={"body": body},
    )
    resp.raise_for_status()

def post_comment(body: str):
    if PR_NUMBER:
        post_pr_comment(body)
    else:
        post_commit_comment(body)

# ── File readers ───────────────────────────────────────────────────────────────
def read_text_files(path: Path) -> str:
    parts = []
    for f in sorted(path.rglob("*")):
        if f.is_file() and f.suffix.lower() in TEXT_EXTS:
            try:
                content = f.read_text(encoding="utf-8", errors="replace")
                parts.append(f"### {f.relative_to(path)}\n```\n{content}\n```")
            except Exception as e:
                parts.append(f"### {f.relative_to(path)}\n[Error: {e}]")
    return "\n\n".join(parts) if parts else ""

def read_image_blocks(path: Path) -> list[dict]:
    blocks = []
    for f in sorted(path.rglob("*")):
        if f.is_file() and f.suffix.lower() in IMAGE_EXTS:
            try:
                data = base64.standard_b64encode(f.read_bytes()).decode()
                ext = f.suffix.lower().lstrip(".")
                media_type = "image/jpeg" if ext in ("jpg", "jpeg") else f"image/{ext}"
                blocks.append({"type": "image", "source": {"type": "base64", "media_type": media_type, "data": data}})
            except Exception as e:
                print(f"[warn] Cannot read image {f}: {e}")
    return blocks

def read_pdf_blocks(path: Path) -> list[dict]:
    blocks = []
    for f in sorted(path.rglob("*")):
        if f.is_file() and f.suffix.lower() == PDF_EXT:
            try:
                data = base64.standard_b64encode(f.read_bytes()).decode()
                blocks.append({"type": "document", "source": {"type": "base64", "media_type": "application/pdf", "data": data}})
            except Exception as e:
                print(f"[warn] Cannot read PDF {f}: {e}")
    return blocks

def extract_diagram_links(path: Path) -> str:
    readme = path / "README.md"
    if not readme.exists():
        return ""
    content = readme.read_text(encoding="utf-8", errors="replace")
    urls = re.findall(r'https?://[^\s\)\"\']+', content)
    keywords = ["figma", "dbdesigner", "drawio", "lucidchart", "miro", "dbdiagram", "erdplus"]
    links = [u for u in urls if any(k in u.lower() for k in keywords)]
    return ("Посилання на діаграму:\n" + "\n".join(links)) if links else ""

# ── Load prompts from private repo ────────────────────────────────────────────
PROMPTS_DIR = Path(".prompts")

def load_prompt(lab_key: str) -> str:
    prompt_file = PROMPTS_DIR / f"{lab_key}.txt"
    if prompt_file.exists():
        return prompt_file.read_text(encoding="utf-8")
    return ""

# ── Read project context from root README ─────────────────────────────────────
def read_project_context() -> str:
    readme = Path("README.md")
    if readme.exists():
        return readme.read_text(encoding="utf-8", errors="replace")
    return "Головний README.md не знайдено."

# ── System prompt ──────────────────────────────────────────────────────────────
SYSTEM_PROMPT = """Ти — досвідчений викладач баз даних, який перевіряє студентські роботи.
Твоя відповідь — це GitHub коментар у форматі Markdown.
Будь конкретним: вказуй назви таблиць, полів, файлів де є проблеми.
Відповідай виключно українською мовою."""

# ── Per-lab review ─────────────────────────────────────────────────────────────
def review_lab(lab_key: str, lab_path: Path, project_context: str, schema_context: str) -> str:
    print(f"[review] {lab_key} ({lab_path.name}) ...")

    text         = read_text_files(lab_path)
    image_blocks = read_image_blocks(lab_path)
    pdf_blocks   = read_pdf_blocks(lab_path)
    diagram_links = extract_diagram_links(lab_path)

    # Завантажуємо промпт з приватного репо
    prompt_template = load_prompt(lab_key)

    # Збираємо контекст для Claude
    context_block = f"""
## Контекст проєкту
Тема бази даних яку обрала команда (з головного README):
{project_context}

## Схема бази даних (topic-03)
{schema_context if schema_context else "Схема з topic-03 не передана або це і є topic-03."}
"""

    user_text = f"{context_block}\n\n{prompt_template}\n\n## Файли студентів\n{text or 'Файли не знайдені'}"
    if diagram_links:
        user_text += f"\n\n{diagram_links}"

    content = []
    content.extend(image_blocks)
    content.extend(pdf_blocks)
    content.append({"type": "text", "text": user_text})

    response = client.messages.create(
        model="claude-haiku-4-5-20251001",
        max_tokens=2000,
        system=SYSTEM_PROMPT,
        messages=[{"role": "user", "content": content}],
    )

    return response.content[0].text

# ── Main ───────────────────────────────────────────────────────────────────────
def main():
    root = Path(".")

    changed_raw = os.environ.get("CHANGED_LABS", "")
    changed_labs = set(changed_raw.split(",")) if changed_raw else set(LABS.keys())
    print(f"[info] Labs to review: {changed_labs}")

    project_context = read_project_context()
    print("[info] Project context loaded from README.md")

    lab1_path = root / LABS["lab1"]
    schema_context = read_text_files(lab1_path) if lab1_path.exists() else ""

    for lab_key, folder_name in LABS.items():
        if lab_key not in changed_labs:
            print(f"[skip] {lab_key} — no changes")
            continue

        lab_path = root / folder_name
        if not lab_path.exists():
            print(f"[skip] {folder_name} not found")
            continue

        try:
            comment = review_lab(lab_key, lab_path, project_context, schema_context)
            post_comment(comment)
            print(f"[ok] {lab_key} comment posted")
        except Exception as e:
            print(f"[error] {lab_key}: {e}", file=sys.stderr)
            error_comment = f"## ❌ {folder_name} — Помилка перевірки\n\n```\n{e}\n```"
            try:
                post_comment(error_comment)
            except Exception:
                pass

if __name__ == "__main__":
    main()