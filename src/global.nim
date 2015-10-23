import common_types

const
  cameraWidth* = 320
  cameraHeight* = 240
  tileMap* = [
    [0, 1, 0, 1, 0, 1, 0],
    [1, 2, 1, 2, 1, 2, 1],
    [2, 3, 2, 3, 2, 3, 2],
    [3, 0, 3, 0, 3, 0, 3],
    [0, 1, 0, 1, 0, 1, 0],
    [1, 2, 1, 2, 1, 2, 1],
    [2, 3, 2, 3, 2, 3, 2],
    [3, 0, 3, 0, 3, 0, 3]
  ]
  tileSize* = 100
  mapView* = view(0, 0, tileMap[0].len * tileSize, tileMap.len * tileSize)
