#!/usr/bin/env python

# WS server example

import asyncio
import websockets
import numpy as np
import msgpack
import msgpack_numpy as m
m.patch()

import lz4.frame

import glob
import natsort

npy_files = glob.glob("E:\\PROJECTS\\bag2ws\\data\\*.npy")
npy_files = natsort.natsorted(npy_files)

xyzs = []
rgbs = []
sizes = []


for npy_file in npy_files:
    with open(npy_file, 'rb') as f:
        data = np.load(f, allow_pickle=True)
        item = data.item()

        xyzs.append(item['xyz'])
        rgbs.append(item['rgb'])
        sizes.append(item['size'])


async def hello(websocket, path):
    for (xyz, rgb, size) in zip(xyzs, rgbs, sizes):
        test_dict = {
            "size": size,
            "pcl": xyz.tobytes(),
            "pcl_color": rgb.tobytes()
        }

        test_packed = msgpack.packb(test_dict, use_bin_type=False)

        await websocket.send(test_packed)

start_server = websockets.serve(hello, "localhost", 8765)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()

