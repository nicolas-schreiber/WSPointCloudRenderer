import rosbag
from sensor_msgs.msg import PointCloud2
import sensor_msgs.point_cloud2 as pc2
import numpy as np
import math
from ctypes import * # convert float to uint32


convert_rgbUint32_to_tuple = lambda rgb_uint32: (
    (rgb_uint32 & 0x00ff0000)>>16, (rgb_uint32 & 0x0000ff00)>>8, (rgb_uint32 & 0x000000ff)
)

convert_rgbFloat_to_tuple = lambda rgb_float: convert_rgbUint32_to_tuple(
    int(cast(pointer(c_float(rgb_float)), POINTER(c_uint32)).contents.value)
)

if __name__ == "__main__":
    bag = rosbag.Bag('..//Downloads/2020-09-22-13-09-30.bag')

    idx = 0
    for topic, msg, t in bag.read_messages(topics=['/merged_pc']):
        field_names=[field.name for field in msg.fields]
        cloud_data = list(pc2.read_points(msg, skip_nans=True, field_names = field_names))
        xyz = [(x,y,z) for x,y,z,rgb in cloud_data ] # (why cannot put this line below rgb?)
        rgb = [rgb for x,y,z,rgb in cloud_data ]

        d = {
            'xyz': np.array(xyz, dtype=np.float32), 
            'rgb': np.array(rgb, dtype=np.float32),
            'size': len(xyz)
        }

        path = "data/{}_pc.npy"
        with open(path.format(idx), 'wb') as f:
            np.save(f, d)
        rgb_ = np.array([rgb[0]], dtype=np.float32).view(np.uint8)
        print(xyz[0], rgb[0])
        idx += 1


    bag.close()