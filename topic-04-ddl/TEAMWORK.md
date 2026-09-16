# TEAMWORK - Topic 04 (SQL DDL)

## Склад команди
- Команда: TEAM-02
- Варіант предметної області: Variant 3 — Restaurant Management System

## Таблиця внесків
| Учасник | Роль у команді | Що зроблено | Артефакти / файли |
|---|---|---|---|
|Vitaliy Fronts|SQL Developer|Simple inventory tracking, Basic restaurant location management|dbml — locations_mvp, ingredients_mvp, location_inventory_mvp, suppliers_final, supplier_ingredients_final|
| Maksym Soloviov |SQL Developer | Menu items and categories and plus write code scheme  | dbml — menu_items_mvp, menu_categories_mvp, menu_item_ingredients_final |
| Valerii Kyrpychenko | SQL Developer | Staff management and basic scheduling |dbml — staff_mvp, shift_schedules_final|
| Oleksii Antypov | SQL Developer | Basic order processing — dine-in and takeaway| dbml — orders_mvp, order_items_mvp, customers_final, customer_feedback_final, reservations_final |

## Контекст теми

Розподіл відповідальності:

Vitaliy Fronts відповідав за блок локацій і складського обліку: locations_mvp, ingredients_mvp, location_inventory_mvp, suppliers_final та supplier_ingredients_final. Ця частина забезпечує облік інгредієнтів, їхніх запасів на різних локаціях, постачальників і закупівельних цін.

Maksym Soloviov відповідав за блок меню: menu_items_mvp, menu_categories_mvp та menu_item_ingredients_final. Ця частина описує категорії меню, страви, їхню вартість, час приготування та склад страв.

Valerii Kyrpychenko відповідав за блок персоналу: staff_mvp та shift_schedules_final. Ця частина зберігає дані працівників, їхню основну локацію та графіки запланованих і фактичних змін.

Oleksii Antypov відповідав за блок замовлень і клієнтської взаємодії: orders_mvp, order_items_mvp, customers_final, customer_feedback_final та reservations_final. Ця частина підтримує замовлення в ресторані й на виніс, позиції замовлень, дані клієнтів, відгуки та бронювання столиків.

## Коротке обґрунтування командного підходу
1. Як ви розподілили DDL-об'єкти між учасниками: ...
2. Чому обрали саме такий поділ роботи: ...
3. Як перевіряли відповідність DDL вашій ER-діаграмі: ...
