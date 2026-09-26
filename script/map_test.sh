cd /home/spr/SPR_Sentry_26
source /opt/ros/humble/setup.bash
colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release

cmds=(
  # 1. 启动 robot_description，发布机器人模型和 TF。
  "source /opt/ros/humble/setup.bash && source install/setup.bash && ros2 launch spr_robot_description robot_description_launch.py"

  # 2. 获取 Livox 点云和 IMU，并启动 Point-LIO、slam_toolbox 进行建图。
  # 点云：/red_standard_robot1/livox/lidar_merged
  # IMU ：/red_standard_robot1/livox/imu_192_168_1_194
  "source /opt/ros/humble/setup.bash && source install/setup.bash && ros2 launch spr_nav_bringup rm_navigation_reality_launch.py slam:=True use_robot_state_pub:=False"
)

for cmd in "${cmds[@]}"; 
do
  echo "Current CMD: $cmd"
  gnome-terminal -- bash -c "cd ${pwd}; $cmd; exec bash"
  sleep 0.5
done

# 3. 保存地图：
# 建图完成后，新开终端，进入工作空间并 source 环境，再执行以下命令。
# 每次只需修改 -f 后面的地图文件名，例如 map_0711。
#
# cd /home/spr/SPR_Sentry_26
# source /opt/ros/humble/setup.bash
# source install/setup.bash
# ros2 run nav2_map_server map_saver_cli -f map_0711 --ros-args -r __ns:=/red_standard_robot1
