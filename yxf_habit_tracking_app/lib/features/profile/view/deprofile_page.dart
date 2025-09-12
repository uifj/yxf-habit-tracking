// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tencent_cloud_chat_common/tencent_cloud_chat_common.dart';
// import 'package:hunnu_auth/hunnu_auth.dart';
// import '../../profile/cubit/profile_cubit.dart';

// /// 个人资料页面
// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   static Route<void> route() {
//     return MaterialPageRoute<void>(builder: (_) => const ProfilePage());
//   }

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends TencentCloudChatState<ProfilePage> {
//   final ScrollController _scrollController = ScrollController();
//   double _appBarOpacity = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_onScroll);
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _onScroll() {
//     final offset = _scrollController.offset;
//     final opacity = (offset / 200).clamp(0.0, 1.0);
//     if (opacity != _appBarOpacity) {
//       setState(() {
//         _appBarOpacity = opacity;
//       });
//     }
//   }

//   @override
//   Widget defaultBuilder(BuildContext context) {
//     return BlocProvider(
//       create: (context) => ProfileCubit(
//         authenticationRepository: context.read<AuthenticationRepository>(),
//       )..loadProfile(),
//       child: Scaffold(
//         backgroundColor: Theme.of(context).colorScheme.surface,
//         body: BlocBuilder<ProfileCubit, ProfileState>(
//           builder: (context, state) {
//             return CustomScrollView(
//               controller: _scrollController,
//               slivers: [
//                 _buildSliverAppBar(context, state),
//                 SliverToBoxAdapter(
//                   child: _buildProfileContent(context, state),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   /// 构建可折叠AppBar
//   Widget _buildSliverAppBar(BuildContext context, ProfileState state) {
//     return SliverAppBar(
//       expandedHeight: 280,
//       floating: false,
//       pinned: true,
//       backgroundColor:
//           Theme.of(context).colorScheme.primary.withOpacity(_appBarOpacity),
//       foregroundColor: Colors.white,
//       flexibleSpace: FlexibleSpaceBar(
//         background: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 Theme.of(context).colorScheme.primary,
//                 Theme.of(context).colorScheme.primary.withOpacity(0.8),
//               ],
//             ),
//           ),
//           child: SafeArea(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 60),
//                 _buildAvatar(context, state),
//                 const SizedBox(height: 16),
//                 Text(
//                   state.user.name ?? '未设置姓名',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   state.user.phone ?? '未绑定手机号',
//                   style: const TextStyle(
//                     color: Colors.white70,
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       actions: [
//         IconButton(
//           onPressed: () => _showEditDialog(context, state),
//           icon: const Icon(Icons.edit, color: Colors.white),
//         ),
//       ],
//     );
//   }

//   /// 构建头像
//   Widget _buildAvatar(BuildContext context, ProfileState state) {
//     return GestureDetector(
//       onTap: () => _showAvatarOptions(context),
//       child: Container(
//         width: 100,
//         height: 100,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           border: Border.all(color: Colors.white, width: 3),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               blurRadius: 10,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: CircleAvatar(
//           radius: 47,
//           backgroundColor: Colors.white,
//           child: state.user.name?.isNotEmpty == true
//               ? Text(
//                   state.user.name!.substring(0, 1).toUpperCase(),
//                   style: TextStyle(
//                     fontSize: 36,
//                     fontWeight: FontWeight.bold,
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                 )
//               : Icon(
//                   Icons.person,
//                   size: 50,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//         ),
//       ),
//     );
//   }

//   /// 构建个人资料内容
//   Widget _buildProfileContent(BuildContext context, ProfileState state) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildInfoSection(context, state),
//           const SizedBox(height: 24),
//           _buildActionSection(context),
//           const SizedBox(height: 24),
//           _buildStatisticsSection(context, state),
//         ],
//       ),
//     );
//   }

//   /// 构建信息区块
//   Widget _buildInfoSection(BuildContext context, ProfileState state) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               '个人信息',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//             ),
//             const SizedBox(height: 16),
//             _buildInfoItem(
//               context,
//               icon: Icons.person_outline,
//               title: '姓名',
//               value: state.user.name ?? '未设置',
//               onTap: () => _showEditNameDialog(context, state.user.name),
//             ),
//             _buildInfoItem(
//               context,
//               icon: Icons.phone_outlined,
//               title: '手机号',
//               value: state.user.phone ?? '未绑定',
//               onTap: () => _showEditPhoneDialog(context, state.user.phone),
//             ),
//             _buildInfoItem(
//               context,
//               icon: Icons.email_outlined,
//               title: '邮箱',
//               value: state.user.email ?? '未设置',
//               onTap: () => _showEditEmailDialog(context, state.user.email),
//             ),
//             // _buildInfoItem(
//             //   context,
//             //   icon: Icons.school_outlined,
//             //   title: '学号',
//             //   value: state.user.studentId ?? '未设置',
//             //   onTap: null, // 学号不可编辑
//             // ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// 构建信息项
//   Widget _buildInfoItem(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     required String value,
//     VoidCallback? onTap,
//   }) {
//     return ListTile(
//       contentPadding: EdgeInsets.zero,
//       leading: Icon(
//         icon,
//         color: Theme.of(context).colorScheme.primary,
//       ),
//       title: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//       subtitle: Text(
//         value,
//         style: TextStyle(
//           color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
//         ),
//       ),
//       trailing: onTap != null ? const Icon(Icons.edit, size: 20) : null,
//       onTap: onTap,
//     );
//   }

//   /// 构建操作区块
//   Widget _buildActionSection(BuildContext context) {
//     return Card(
//       child: Column(
//         children: [
//           ListTile(
//             leading: Icon(
//               Icons.lock_outline,
//               color: Theme.of(context).colorScheme.primary,
//             ),
//             title: const Text('修改密码'),
//             subtitle: const Text('更改登录密码'),
//             trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//             onTap: () => _showChangePasswordDialog(context),
//           ),
//           const Divider(height: 1),
//           ListTile(
//             leading: Icon(
//               Icons.privacy_tip_outlined,
//               color: Theme.of(context).colorScheme.primary,
//             ),
//             title: const Text('隐私设置'),
//             subtitle: const Text('管理个人隐私'),
//             trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//             onTap: () {
//               // TODO: 跳转到隐私设置页面
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   /// 构建统计区块
//   Widget _buildStatisticsSection(BuildContext context, ProfileState state) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               '使用统计',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildStatItem(
//                     context,
//                     title: '登录天数',
//                     value: '${state.loginDays}',
//                     icon: Icons.calendar_today,
//                   ),
//                 ),
//                 Expanded(
//                   child: _buildStatItem(
//                     context,
//                     title: '消息数量',
//                     value: '${state.messageCount}',
//                     icon: Icons.message,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// 构建统计项
//   Widget _buildStatItem(
//     BuildContext context, {
//     required String title,
//     required String value,
//     required IconData icon,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       margin: const EdgeInsets.symmetric(horizontal: 4),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           Icon(
//             icon,
//             color: Theme.of(context).colorScheme.primary,
//             size: 32,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Theme.of(context).colorScheme.primary,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 12,
//               color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// 显示头像选项
//   void _showAvatarOptions(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.camera_alt),
//               title: const Text('拍照'),
//               onTap: () {
//                 Navigator.pop(context);
//                 // TODO: 实现拍照功能
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: const Text('从相册选择'),
//               onTap: () {
//                 Navigator.pop(context);
//                 // TODO: 实现相册选择功能
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.cancel),
//               title: const Text('取消'),
//               onTap: () => Navigator.pop(context),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// 显示编辑对话框
//   void _showEditDialog(BuildContext context, ProfileState state) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('编辑资料'),
//         content: const Text('选择要编辑的信息'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('取消'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _showEditNameDialog(context, state.user.name);
//             },
//             child: const Text('编辑姓名'),
//           ),
//         ],
//       ),
//     );
//   }

//   /// 显示编辑姓名对话框
//   void _showEditNameDialog(BuildContext context, String? currentName) {
//     final controller = TextEditingController(text: currentName);
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('编辑姓名'),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(
//             labelText: '姓名',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('取消'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               context.read<ProfileCubit>().updateName(controller.text);
//             },
//             child: const Text('保存'),
//           ),
//         ],
//       ),
//     );
//   }

//   /// 显示编辑手机号对话框
//   void _showEditPhoneDialog(BuildContext context, String? currentPhone) {
//     final controller = TextEditingController(text: currentPhone);
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('编辑手机号'),
//         content: TextField(
//           controller: controller,
//           keyboardType: TextInputType.phone,
//           decoration: const InputDecoration(
//             labelText: '手机号',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('取消'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               context.read<ProfileCubit>().updatePhone(controller.text);
//             },
//             child: const Text('保存'),
//           ),
//         ],
//       ),
//     );
//   }

//   /// 显示编辑邮箱对话框
//   void _showEditEmailDialog(BuildContext context, String? currentEmail) {
//     final controller = TextEditingController(text: currentEmail);
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('编辑邮箱'),
//         content: TextField(
//           controller: controller,
//           keyboardType: TextInputType.emailAddress,
//           decoration: const InputDecoration(
//             labelText: '邮箱',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('取消'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               context.read<ProfileCubit>().updateEmail(controller.text);
//             },
//             child: const Text('保存'),
//           ),
//         ],
//       ),
//     );
//   }

//   /// 显示修改密码对话框
//   void _showChangePasswordDialog(BuildContext context) {
//     final oldPasswordController = TextEditingController();
//     final newPasswordController = TextEditingController();
//     final confirmPasswordController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('修改密码'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: oldPasswordController,
//               obscureText: true,
//               decoration: const InputDecoration(
//                 labelText: '当前密码',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: newPasswordController,
//               obscureText: true,
//               decoration: const InputDecoration(
//                 labelText: '新密码',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: confirmPasswordController,
//               obscureText: true,
//               decoration: const InputDecoration(
//                 labelText: '确认新密码',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('取消'),
//           ),
//           TextButton(
//             onPressed: () {
//               if (newPasswordController.text !=
//                   confirmPasswordController.text) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('两次输入的密码不一致')),
//                 );
//                 return;
//               }
//               Navigator.pop(context);
//               context.read<ProfileCubit>().changePassword(
//                     oldPasswordController.text,
//                     newPasswordController.text,
//                   );
//             },
//             child: const Text('确定'),
//           ),
//         ],
//       ),
//     );
//   }
// }
