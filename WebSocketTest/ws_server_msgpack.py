#!/usr/bin/env python

# WS server example

import asyncio
import websockets
import numpy as np
import msgpack
import msgpack_numpy as m
m.patch()


async def hello(websocket, path):

    while True:
        test_size = 100000
        test_pcl = np.array(np.random.rand(test_size,3), dtype=np.float32)
        test_pcl_color = np.array(np.random.rand(test_size,4) * 255, dtype=np.uint8)

        test_dict = {
            "size": test_size,
            "pcl": test_pcl.tobytes(),
            "pcl_color": test_pcl_color.tobytes()
        }

        test_packed = msgpack.packb(test_dict, use_bin_type=False)

        await websocket.send(test_packed)

        await asyncio.sleep(0.05)

start_server = websockets.serve(hello, "localhost", 8765)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()

