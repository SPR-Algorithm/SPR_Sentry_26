#!/usr/bin/env bash

set -e

# 默认认为该脚本位于 ROS 2 工作空间的 script/ 目录下。
# 如需指定其他工作空间：ROS_WORKSPACE=/path/to/ws ./script/map_online.sh
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="${ROS_WORKSPACE:-$(cd -- "${SCRIPT_DIR}/.." && pwd)}"
ROBOT_NAMESPACE="${ROBOT_NAMESPACE:-red_standard_robot1}"

cd "${WORKSPACE}"

source /opt/ros/humble/setup.bash
colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release

cmds=(
  # 1. 启动 robot_description，发布机器人模型和 TF。
  "source /opt/ros/humble/setup.bash && source install/setup.bash && ros2 launch spr_robot_description robot_description_launch.py namespace:=${ROBOT_NAMESPACE}"

  # 2. 获取 Livox 点云和 IMU，并启动 Point-LIO、slam_toolbox 进行建图。
  # 点云：/${ROBOT_NAMESPACE}/livox/lidar_merged
  # IMU ：/${ROBOT_NAMESPACE}/livox/imu_192_168_1_194
  "source /opt/ros/humble/setup.bash && source install/setup.bash && ros2 launch spr_nav_bringup rm_navigation_reality_launch.py namespace:=${ROBOT_NAMESPACE} slam:=True use_robot_state_pub:=False"
)

for cmd in "${cmds[@]}"; do
  echo "Current CMD: ${cmd}"
  gnome-terminal -- bash -c "cd '${WORKSPACE}'; ${cmd}; exec bash"
  sleep 0.5
done

# 3. 保存地图：
# 建图完成后，新开终端，进入工作空间并 source 环境，再执行以下命令。
# 每次只需修改 -f 后面的地图文件名，例如 map_0711。
#
# cd /home/spr/new_ws
# source /opt/ros/humble/setup.bash
# source install/setup.bash
# ros2 run nav2_map_server map_saver_cli -f map_0711 --ros-args -r __ns:=/red_standard_robot1
