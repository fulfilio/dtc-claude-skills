---
name: fulfillment-optimization
description: Analyzes warehouse shipment backlogs to optimize batch picking and packing workflows. Use when a merchant needs help clearing order backlogs, improving picking efficiency, optimizing batch sizes, or understanding order composition patterns. Triggers on questions about shipping delays, picking strategies, packing station setup, warehouse workflow optimization, or order fulfillment bottlenecks. Works with Fulfil MCP data or user-provided shipment data (CSV/Excel).
---

# Fulfillment Optimization Analysis

Analyzes shipment data to generate actionable recommendations for clearing backlogs and optimizing warehouse workflows.

## Data Sources

**Option 1: Fulfil MCP Connection**
Query the `shipments` table with nested `moves` for line-item detail. Key fields:
- `state` (assigned, waiting, done, packed, cancel)
- `warehouse` for location filtering
- `moves.order_channel_name` for channel filtering
- `moves.product_code`, `moves.quantity`, `moves.product_name`
- `shipped_date` for velocity analysis

**Option 2: User-Provided Data**
Accept CSV/Excel with minimum columns: shipment_id, sku, quantity, status. Optional: ship_date, warehouse, channel.

## Analysis Workflow

### 1. Scope Confirmation
Before analysis, confirm with user:
- Which sales channel(s)?
- Which warehouse(s)?
- Focus on assigned/waiting shipments or include recent shipped for patterns?

### 2. Core Metrics to Calculate

**Order Composition**
```sql
-- Single vs multi-unit distribution
SELECT 
  CASE WHEN total_units = 1 THEN '1 unit'
       WHEN total_units = 2 THEN '2 units'
       WHEN total_units BETWEEN 3 AND 5 THEN '3-5 units'
       ELSE '6+ units' END as bucket,
  COUNT(*) as shipments,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) as pct
FROM (
  SELECT s.id, SUM(m.quantity) as total_units
  FROM shipments s, UNNEST(moves) m
  WHERE [filters] AND m.move_type = 'outgoing' AND m.state != 'cancelled'
  GROUP BY s.id
)
GROUP BY bucket
```

**SKU Line Distribution**
Same pattern but `COUNT(DISTINCT m.product_code)` for unique SKUs per order.

**Top SKUs by Frequency**
```sql
SELECT m.product_code, COUNT(DISTINCT s.id) as orders, SUM(m.quantity) as units
FROM shipments s, UNNEST(moves) m
WHERE [filters]
GROUP BY m.product_code
ORDER BY orders DESC LIMIT 20
```

**Product Pairing Analysis** (for co-location)
```sql
-- Find products frequently bought together
WITH pairs AS (
  SELECT LEAST(a.product_code, b.product_code) as sku1,
         GREATEST(a.product_code, b.product_code) as sku2
  FROM shipment_products a
  JOIN shipment_products b ON a.shipment_id = b.shipment_id AND a.product_code < b.product_code
)
SELECT sku1, sku2, COUNT(*) as frequency
FROM pairs GROUP BY sku1, sku2 ORDER BY frequency DESC
```

**Shipping Velocity** (last 7 days)
```sql
SELECT shipped_date, COUNT(DISTINCT id) as shipments
FROM shipments WHERE state = 'done' AND shipped_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
GROUP BY shipped_date ORDER BY shipped_date
```

### 3. Identify Batch Picking Opportunities

**High-Volume Single-SKU Candidates (Pre-Print & Pack)**
- Threshold: ≥1 case quantity of single-unit orders for that SKU
- If case quantities unavailable, use ~20-30 as proxy
- These orders can have labels pre-printed, products brought to station in bulk

**Low-Volume Single-Unit (Mixed Batch)**
- SKUs with <1 case worth of single-unit orders
- Combine into one mixed-SKU batch
- Requires packing station with scan-to-label workflow

### 4. Check for Blockers

**Inventory Status** (if available)
Query `inventory_by_location` to compare available vs. needed for top SKUs.
- Exclude bundle/kit SKUs from shortage flags (built on the fly)
- Flag non-bundle SKUs with demand > available

**Bundle Identification**
SKUs with "BUNDLE" in code/name are typically assembled from components—don't flag inventory issues.

### 5. Location Analysis

**Primary Pick Locations**
```sql
SELECT product_code, location_name, quantity_available
FROM inventory_by_location
WHERE product_code IN ([top_skus]) AND quantity_available > 0
ORDER BY product_code, quantity_available DESC
```

## Recommendation Framework

Generate 4-5 recommendations following this structure:

### Recommendation 1: Pre-Print & Pack (High-Volume Singles)
**When:** SKU has ≥1 case worth of single-unit orders
**Process:**
1. Grab full cases/pallet of SKU
2. Increase batch size substantially (all orders for that SKU)
3. Pre-print all labels regardless of carrier
4. Sort by carrier while packing (or split into carrier-specific batches)
5. Apply label and ship

**Include:** Table of candidate SKUs with order counts and primary locations

### Recommendation 2: Mixed Single-Unit Batch (Low-Volume)
**When:** Single-unit orders where SKU has <1 case worth
**Process:**
1. Create one mixed-SKU batch for all low-volume singles
2. Pick all items in one pass
3. Bring to packing station
4. Scan item → system prints correct label

### Recommendation 3: Multi-SKU Order Handling
**Key insight:** Packing is typically the bottleneck, not picking
**Process:**
1. Co-locate high-frequency product pairs where possible
2. Must use packing station for efficient workflow
3. Scan items → verify complete → pack → label

**Include:** Top product pairs table for co-location

### Recommendation 4: Packing Station Capacity
**Staffing model:** 1-2 pickers : 3-4 packers (1:2 ratio)
**Each station needs:**
- Computer or tablet (for packing interface)
- Thermal label printer
- Barcode scanner

### Recommendation 5: Cartonization (if applicable)
Note status of default box type configuration.
Offer assistance with multi-unit cartonization if needed.

## Output Format

Generate PDF report with:
1. Executive summary (backlog size, days of work at current velocity)
2. Order composition analysis (tables + key stats)
3. Top SKUs with batch picking candidates
4. Product pairing analysis
5. Numbered recommendations with process steps
6. Wave execution plan (table showing wave → description → shipments → method)
7. Shipping velocity (last 7 days)
8. Bottom line summary

Use `docx` skill to create document, then convert to PDF:
```bash
soffice --headless --convert-to pdf document.docx --outdir /mnt/user-data/outputs/
```

## Key Principles

1. **72/17/11 rule**: Typical DTC order composition is ~70% single-unit, ~17% two-item, ~13% complex. Optimize for the majority first.

2. **Packing > Picking**: In most operations, packing is the constraint. Recommend 1:2 picker-to-packer ratio.

3. **Bundle awareness**: Built-on-fly bundles don't have inventory—components do. Never flag bundle inventory issues.

4. **Case quantity threshold**: The dividing line between "Pre-Print & Pack" and "Mixed Batch" workflows. If not in system, estimate ~20-30 units.

5. **Pre-print enables speed**: When cartonization/default boxes are configured, labels can be pre-printed for single-unit orders.
