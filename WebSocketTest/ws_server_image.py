#!/usr/bin/env python

import cv2

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

cv_image = cv2.imread('asdf.jpg',0)

async def hello(websocket, path):
    while True:
        test_dict = {
            "data": np.array(cv2.imencode(".jpg", cv_image)[1]).tostring()
        }

        test_packed = msgpack.packb(test_dict, use_bin_type=False)

        await websocket.send(test_packed)

start_server = websockets.serve(hello, "localhost", 8765)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()

