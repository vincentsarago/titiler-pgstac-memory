### 1. Launch the services and Ingest data

```
docker compose up -d

python -m venv .venv
source .venv/bin/activate

python -m pip install -r requirements.txt

.venv/bin/pypgstac load collections stac/collection.json --dsn postgresql://username:password@0.0.0.0:5439/postgis
.venv/bin/pypgstac load items stac/items.json --dsn postgresql://username:password@0.0.0.0:5439/postgis
```

use `http://localhost:8080` to monitor the memory/CPU usage


### 2. Hit the mosaic endpoint

```python
import httpx

resp = httpx.post("http://0.0.0.0:8081/mosaic/register", json={
    "collections": ["world"]
    }
)
print(resp.json())

>> {'searchid': '6bf03e6b8cbf8b68443cf2123e901f44', 'links': [{'rel': 'metadata', 'title': 'Mosaic metadata', 'type': 'application/json', 'href': 'http://0.0.0.0:8081/mosaic/6bf03e6b8cbf8b68443cf2123e901f44/info'}, {'rel': 'tilejson', 'title': 'Link for TileJSON', 'type': 'application/json', 'href': 'http://0.0.0.0:8081/mosaic/6bf03e6b8cbf8b68443cf2123e901f44/tilejson.json'}, {'rel': 'map', 'title': 'Link for Map viewer', 'type': 'application/json', 'href': 'http://0.0.0.0:8081/mosaic/6bf03e6b8cbf8b68443cf2123e901f44/map'}, {'rel': 'wmts', 'title': 'Link for WMTS', 'type': 'application/json', 'href': 'http://0.0.0.0:8081/mosaic/6bf03e6b8cbf8b68443cf2123e901f44/WMTSCapabilities.xml'}]}
```

```python
import httpx
import morecantile
from random import sample

tilematrixset = morecantile.tms.get("WebMercatorQuad")
w, s, e, n = [-180, -90, 180, 90]
minzoom = 1
maxzoom = 4

extrema = {}
for zoom in range(minzoom, maxzoom + 1):
    ul_tile = tilematrixset.tile(w, n, zoom)
    lr_tile = tilematrixset.tile(e, s, zoom)
    extrema[zoom] = {
        "x": {"min": ul_tile.x, "max": lr_tile.x + 1},
        "y": {"min": ul_tile.y, "max": lr_tile.y + 1},
    }

while True:
    z = sample(range(minzoom, maxzoom + 1), 1)[0]
    x = sample(range(extrema[z]["x"]["min"], extrema[z]["x"]["max"]), 1)[0]
    y = sample(range(extrema[z]["y"]["min"], extrema[z]["y"]["max"]), 1)[0]
    _ = httpx.get(
        f"http://0.0.0.0:8081/mosaic/6bf03e6b8cbf8b68443cf2123e901f44/tiles/WebMercatorQuad/{z}/{x}/{y}.png?assets=asset",
        timeout=30,
    )
```
