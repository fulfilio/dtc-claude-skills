# Report Structure Reference

## Document Sections

### 1. Title Block
- Report title: "[Channel Name] Batch Picking & Packing Optimization"
- Subtitle: "Warehouse: [Warehouse Name] ([Code])"
- Date generated

### 2. Executive Summary
Single paragraph covering:
- Total assigned shipments count
- Days of work at current velocity
- Key composition stat (e.g., "72% are single-SKU, single-unit orders")
- Primary optimization opportunity

### 3. Order Composition Analysis
Two tables:

**Unit Distribution Table**
| Units per Order | Shipments | % of Total |
|-----------------|-----------|------------|
| 1 unit          | X         | X%         |
| 2 units         | X         | X%         |
| 3-5 units       | X         | X%         |
| 6+ units        | X         | X%         |

**SKU Line Distribution Table**
| SKUs per Order  | Shipments | % of Total |
|-----------------|-----------|------------|
| 1 SKU           | X         | X%         |
| 2 SKUs          | X         | X%         |
| 3+ SKUs         | X         | X%         |

### 4. Top SKUs Table
| SKU | Orders | % | Type |
|-----|--------|---|------|
| ... | ...    | % | Standard/Built-on-fly |

Highlight bundles in different color, note they require no assembly.

### 5. Recommendations (4-5 total)
Each recommendation includes:
- **Numbered heading** with descriptive title
- **Target:** What orders this applies to
- **Process:** Numbered steps
- **Impact box:** Highlighted summary of expected outcome

### 6. Pre-Print & Pack Candidates Table
| SKU | Single-Unit Orders | Primary Location | Default Box |
|-----|-------------------|------------------|-------------|

### 7. Product Pairing Table
| Product 1 | Product 2 | Frequency |
|-----------|-----------|-----------|

### 8. Packing Station Setup
Staffing table:
| Role | Recommended | Ratio |
|------|-------------|-------|
| Pickers | 1-2 | 1:2 |
| Packing Stations | 3-4 | |

Equipment list per station.

### 9. Wave Execution Plan
| Wave | Description | Shipments | Method |
|------|-------------|-----------|--------|
| 1 | ... | ~X | Pre-Print & Pack |
| 2 | ... | ~X | Packing Station |

Color-code by method (green = Pre-Print, blue = Packing Station).

### 10. Shipping Velocity Table
| Date | Shipments | Units |
|------|-----------|-------|
Last 7 days with average noted below.

### 11. Bottom Line
3-4 bullet points summarizing expected outcomes if recommendations implemented.

## Formatting Guidelines

- Use consistent color scheme (blue headers, green for high-impact items)
- Highlight bundles/built-on-fly items in yellow
- Bold key statistics
- Keep tables compact with right-aligned numbers
- Add italicized notes below tables where clarification needed

## SQL Query Patterns

### Filter Template (Fulfil)
```sql
WHERE m.order_channel_name = '[Channel]'
  AND s.state = 'assigned'
  AND s.warehouse = '[Warehouse]'
  AND m.state != 'cancelled'
  AND m.move_type = 'outgoing'
```

### Single-SKU Order Identification
```sql
WITH shipment_sku_counts AS (
  SELECT s.id, COUNT(DISTINCT m.product_code) as sku_count,
         MAX(m.product_code) as single_sku
  FROM shipments s, UNNEST(s.moves) as m
  WHERE [filters]
  GROUP BY s.id
)
SELECT single_sku as sku, COUNT(*) as single_sku_orders
FROM shipment_sku_counts
WHERE sku_count = 1
GROUP BY single_sku
ORDER BY single_sku_orders DESC
```

### Bundle Detection
```sql
WHERE UPPER(m.product_code) LIKE '%BUNDLE%' 
   OR UPPER(m.product_name) LIKE '%BUNDLE%'
```
