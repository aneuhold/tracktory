# US-003: Default Categories

**As a** new user  
**I want** to see pre-defined categories for my items  
**So that** I can quickly organize my belongings without setup work

## Acceptance Criteria

- [ ] System provides default categories on first use
- [ ] Categories include: Electronics, Furniture, Tools, Clothing, Books, Kitchen, Sports, Garden, Automotive, Other
- [ ] Categories appear in alphabetical order in selection lists
- [ ] User can create items without selecting a category (defaults to "Uncategorized")
- [ ] Categories have appropriate icons for visual recognition
- [ ] Category list loads quickly (< 500ms) on mobile

## Default Categories List

1. **Automotive** - Cars, motorcycles, car parts
2. **Books** - Physical books, manuals, reference materials
3. **Clothing** - Apparel, shoes, accessories
4. **Electronics** - Computers, phones, gadgets, cables
5. **Furniture** - Tables, chairs, beds, storage
6. **Garden** - Tools, plants, outdoor equipment
7. **Kitchen** - Appliances, cookware, utensils
8. **Sports** - Exercise equipment, sporting goods
9. **Tools** - Hand tools, power tools, hardware
10. **Other** - Items that don't fit other categories

## Technical Notes

- Categories seeded during database initialization
- Read-only for MVP (no user category creation)
- Simple flat structure (no subcategories in Phase 1)

## Status & Metadata

- **Status**: Ready
- **Priority**: Medium
- **Estimate**: 3 points
- **Dependencies**: None (can use database seeds)
- **API Endpoints**: `GET /categories`
