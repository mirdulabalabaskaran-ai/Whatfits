# WhatFits

A Spring Boot + PostgreSQL fashion size recommendation application. The UI is served by the same Spring Boot origin, so it calls the API through relative `/api/v1/...` URLs.

## Quick start

### Prerequisites

- Java 11+
- Maven 3.8+
- PostgreSQL 14+ (or Docker Compose)

### Start PostgreSQL

```bash
docker compose up -d postgres
# creates database/user/password: whatfits / whatfits / whatfits
```

Or set `DB_URL`, `DB_USERNAME`, and `DB_PASSWORD` for an existing PostgreSQL database. Example:

```bash
export DB_URL='jdbc:postgresql://localhost:5432/whatfits'
export DB_USERNAME='whatfits'
export DB_PASSWORD='change-me'
```

### Run the application

```bash
mvn clean compile
mvn spring-boot:run
# http://localhost:8080
```

### Easier Windows start (no SQL tool required)

After installing and opening Docker Desktop plus Maven, double-click `Start-WhatFits.bat` in the project folder. It starts the PostgreSQL container and the application. When it says `Started WhatFitsApplication`, open `http://localhost:8080`. Double-click `Stop-WhatFits-Database.bat` when finished.

JPA uses `ddl-auto=update`, creating the following tables without dropping existing data: `brands`, `products`, `product_variants`, `product_available_sizes`, `brand_size_charts`, `user_measurements`, and `recommendation_records`.

The first startup seeds three **source-linked**, database-backed products only when the `products` table is empty:

- Zara — Regular Fit Shirt
- H&M — Regular Fit T-shirt
- Levi's — Men's Solid Slim Fit T-shirt

Each has an official product URL. The seeded product-specific images are locally served copies fetched from the respective official India product pages so product cards do not depend on retailer hotlink rules; the product page stays in `catalogueSourceUrl` as provenance. Prices, stock and URLs can change at the retailer, so the official page remains the source of truth. Disable seeding with `WHATFITS_SEED_CATALOGUE=false`.

## API

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/api/v1/brands` | List brands |
| GET | `/api/v1/brands/{id}/size-charts` | List stored size-chart rows |
| GET | `/api/v1/products?brand=Zara&category=SHIRTS&q=shirt` | List/filter database products |
| GET | `/api/v1/products/{id}` | Get one product |
| POST | `/api/v1/products` | Create a product (validated) |
| PUT | `/api/v1/products/{id}` | Replace/update a product (validated) |
| DELETE | `/api/v1/products/{id}` | Delete a product |
| POST | `/api/v1/recommendations` | Product-specific recommendation and cross-brand comparison |
| POST | `/api/v1/brand-comparison` | Alias for comparison workflow |
| POST | `/api/v1/measurements` | Persist a measurement only when a calling client intentionally requests it |

### Example recommendation request

```bash
curl -X POST http://localhost:8080/api/v1/recommendations \
  -H 'Content-Type: application/json' \
  -d '{"productId":3,"measurements":{"chestCm":94,"fitPreference":"REGULAR","gender":"MEN"}}'
```

## Accuracy and catalogue policy

- The UI is **API-driven**; `js/products-data.js` deliberately contains no product inventory fallback.
- An image is rendered as verified only when the product record marks it `imageVerified=true`; otherwise the UI says “Image unavailable.”
- Product variant values are explained as listed garment/product-page measurements. The recommendation response marks this estimate as uncertain rather than presenting it as a body-size guarantee.
- `BrandSizeChart` is implemented for imported documented body-size ranges. No generic Zara/H&M/Levi's brand chart is invented by the seed data. Add a source URL and set `verified=true` only after validating a current documented size guide.
- The image uploader validates JPG/JPEG/PNG/WEBP and a 5 MB maximum, requires a local consent checkbox, uses a browser-only Object URL preview, and does not send the photo to this backend. Image recognition is intentionally not claimed because no vision service is configured.
- The built-in WebGL avatar is a simplified primitive-mesh mannequin bundled with the app. `Product.modelType` is stored and exposed by the Product API; the frontend uses that database-backed category/model type, selected brand, measurements, and fit preference to update the visual silhouette. It is a visual aid, not a body scan or a virtual try-on guarantee.
- The write endpoints are intentionally open in this baseline because no authentication layer existed in the supplied workspace. Add Spring Security/roles before exposing them publicly.

## Tests

```bash
mvn test
```

Tests use an isolated H2 database in PostgreSQL compatibility mode to exercise JPA table creation, seeded product retrieval, the Product API, and recommendations. Run the app against PostgreSQL as above to verify the production driver and schema on a real database.
