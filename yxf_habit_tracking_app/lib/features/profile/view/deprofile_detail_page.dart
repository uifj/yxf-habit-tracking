// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tencent_cloud_chat_common/tencent_cloud_chat_common.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:hunnu_auth/hunnu_auth.dart';
// import '../../profile/cubit/profile_cubit.dart';

// /// 个人资料详情页面
// class ProfileDetailPage extends StatefulWidget {
//   const ProfileDetailPage({super.key});

//   static Route<void> route() {
//     return MaterialPageRoute<void>(
//       builder: (_) => const ProfileDetailPage(),
//     );
//   }

//   @override
//   State<ProfileDetailPage> createState() => _ProfileDetailPageState();
// }

// class _ProfileDetailPageState extends TencentCloudChatState<ProfileDetailPage> {
//   @override
//   void initState() {
//     super.initState();
//     // 触发加载用户信息
//     context.read<ProfileCubit>().loadProfile();
//   }

//   @override
//   Widget defaultBuilder(BuildContext context) {
//     return BlocBuilder<ProfileCubit, ProfileState>(
//       builder: (context, state) {
//         return Scaffold(
//           backgroundColor: Theme.of(context).colorScheme.surface,
//           appBar: _buildAppBar(),
//           body: _buildBody(state),
//         );
//       },
//     );
//   }

//   /// 构建应用栏
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       title: const Text('个人信息'),
//       elevation: 0,
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       foregroundColor: Theme.of(context).colorScheme.onSurface,
//       actions: [
//         IconButton(
//           onPressed: () => _showEditDialog(),
//           icon: const Icon(Icons.edit_outlined),
//           tooltip: '编辑资料',
//         ),
//       ],
//     );
//   }

//   /// 构建页面主体
//   Widget _buildBody(ProfileState state) {
//     if (state.isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(),
//       );
//     }

//     // 如果有错误状态，显示错误信息
//     // TODO: 根据实际的ProfileState实现错误处理

//     return RefreshIndicator(
//       onRefresh: () async => context.read<ProfileCubit>().loadProfile(),
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             _buildProfileHeader(state.user),
//             const SizedBox(height: 24),
//             _buildBasicInfoSection(state.user),
//             const SizedBox(height: 16),
//             _buildContactInfoSection(state.user),
//             const SizedBox(height: 16),
//             _buildIdentityInfoSection(state.user),
//             const SizedBox(height: 24),
//             _buildActionButtons(),
//           ],
//         ),
//       ),
//     );
//   }

//   /// 构建个人资料头部
//   Widget _buildProfileHeader(UserModel user) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           children: [
//             Stack(
//               children: [
//                 CircleAvatar(
//                   radius: 50,
//                   backgroundColor:
//                       Theme.of(context).colorScheme.primary.withOpacity(0.1),
//                   child: (user.avatarDate?.isNotEmpty == true)
//                       ? ClipOval(
//                           child: CachedNetworkImage(
//                             imageUrl:
//                                 'https://example.com/avatar/${user.avatarDate}',
//                             width: 100,
//                             height: 100,
//                             fit: BoxFit.cover,
//                             placeholder: (context, url) =>
//                                 const CircularProgressIndicator(),
//                             errorWidget: (context, url, error) => Icon(
//                               Icons.person,
//                               size: 50,
//                               color: Theme.of(context).colorScheme.primary,
//                             ),
//                           ),
//                         )
//                       : Icon(
//                           Icons.person,
//                           size: 50,
//                           color: Theme.of(context).colorScheme.primary,
//                         ),
//                 ),
//                 Positioned(
//                   bottom: 0,
//                   right: 0,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).colorScheme.primary,
//                       shape: BoxShape.circle,
//                     ),
//                     child: IconButton(
//                       onPressed: () => _showAvatarOptions(),
//                       icon: Icon(
//                         Icons.camera_alt,
//                         color: Theme.of(context).colorScheme.onPrimary,
//                         size: 16,
//                       ),
//                       iconSize: 16,
//                       padding: const EdgeInsets.all(8),
//                       constraints: const BoxConstraints(
//                         minWidth: 32,
//                         minHeight: 32,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               user.displayName,
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             if (user.uniCode?.isNotEmpty == true) ...[
//               const SizedBox(height: 4),
//               Text(
//                 '编号: ${user.uniCode}',
//                 style: TextStyle(
//                   color:
//                       Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   /// 构建基本信息区块
//   Widget _buildBasicInfoSection(UserModel user) {
//     return _buildInfoCard(
//       title: '基本信息',
//       icon: Icons.person_outline,
//       children: [
//         _buildInfoItem(
//           label: '姓名',
//           value: user.displayName,
//           icon: Icons.badge_outlined,
//           onTap: () => _showEditNameDialog(),
//         ),
//         _buildInfoItem(
//           label: '性别',
//           value: user.genderText,
//           icon: Icons.wc_outlined,
//           onTap: () => _showGenderSelector(),
//         ),
//         _buildInfoItem(
//           label: '身份证号',
//           value: user.certificateNum?.isNotEmpty == true
//               ? _maskIdCard(user.certificateNum!)
//               : '未设置',
//           icon: Icons.credit_card_outlined,
//           onTap: () => _showEditIdCardDialog(),
//         ),
//       ],
//     );
//   }

//   /// 构建联系信息区块
//   Widget _buildContactInfoSection(UserModel user) {
//     return _buildInfoCard(
//       title: '联系信息',
//       icon: Icons.contact_phone_outlined,
//       children: [
//         _buildInfoItem(
//           label: '手机号码',
//           value:
//               user.phone?.isNotEmpty == true ? _maskPhone(user.phone!) : '未设置',
//           icon: Icons.phone_outlined,
//           onTap: () => _showEditPhoneDialog(),
//         ),
//         _buildInfoItem(
//           label: '邮箱地址',
//           value: user.email?.isNotEmpty == true ? user.email! : '未设置',
//           icon: Icons.email_outlined,
//           onTap: () => _showEditEmailDialog(),
//         ),
//       ],
//     );
//   }

//   /// 构建身份信息区块
//   Widget _buildIdentityInfoSection(UserModel user) {
//     return _buildInfoCard(
//       title: '身份信息',
//       icon: Icons.school_outlined,
//       children: [
//         _buildInfoItem(
//           label: '学号/工号',
//           value: user.uniCode?.isNotEmpty == true ? user.uniCode! : '未设置',
//           icon: Icons.numbers_outlined,
//         ),
//         _buildInfoItem(
//           label: '用户类型',
//           value: user.primaryRole?.displayName ?? '未知',
//           icon: Icons.account_circle_outlined,
//         ),
//       ],
//     );
//   }

//   /// 构建信息卡片
//   Widget _buildInfoCard({
//     required String title,
//     required IconData icon,
//     required List<Widget> children,
//   }) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   icon,
//                   size: 20,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }

//   /// 构建信息项
//   Widget _buildInfoItem({
//     required String label,
//     required String value,
//     required IconData icon,
//     VoidCallback? onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//         child: Row(
//           children: [
//             Icon(
//               icon,
//               size: 16,
//               color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     label,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Theme.of(context)
//                           .colorScheme
//                           .onSurface
//                           .withOpacity(0.6),
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     value,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (onTap != null)
//               Icon(
//                 Icons.chevron_right,
//                 size: 16,
//                 color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// 构建操作按钮
//   Widget _buildActionButtons() {
//     return Column(
//       children: [
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton.icon(
//             onPressed: () => _showEditDialog(),
//             icon: const Icon(Icons.edit_outlined),
//             label: const Text('编辑资料'),
//           ),
//         ),
//         const SizedBox(height: 8),
//         SizedBox(
//           width: double.infinity,
//           child: OutlinedButton.icon(
//             onPressed: () => _exportProfile(),
//             icon: const Icon(Icons.download_outlined),
//             label: const Text('导出资料'),
//           ),
//         ),
//       ],
//     );
//   }

//   /// 获取性别文本
//   String _getGenderText(String gender) {
//     switch (gender) {
//       case '1':
//         return '男';
//       case '2':
//         return '女';
//       default:
//         return '未设置';
//     }
//   }

//   /// 获取用户类型文本
//   String _getUserTypeText(String userType) {
//     switch (userType) {
//       case 'student':
//         return '学生';
//       case 'teacher':
//         return '教师';
//       case 'staff':
//         return '职工';
//       default:
//         return '未知';
//     }
//   }

//   /// 脱敏身份证号
//   String _maskIdCard(String idCard) {
//     if (idCard.length < 8) return idCard;
//     return '${idCard.substring(0, 4)}****${idCard.substring(idCard.length - 4)}';
//   }

//   /// 脱敏手机号
//   String _maskPhone(String phone) {
//     if (phone.length < 8) return phone;
//     return '${phone.substring(0, 3)}****${phone.substring(phone.length - 4)}';
//   }

//   /// 显示头像选项
//   void _showAvatarOptions() {
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
//                 _takePhoto();
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: const Text('从相册选择'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickFromGallery();
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.delete),
//               title: const Text('删除头像'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _removeAvatar();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// 显示编辑对话框
//   void _showEditDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('编辑资料'),
//         content: const Text('此功能正在开发中，敬请期待。'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('确定'),
//           ),
//         ],
//       ),
//     );
//   }

//   /// 显示编辑姓名对话框
//   void _showEditNameDialog() {
//     final controller = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('编辑姓名'),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(
//             labelText: '姓名',
//             hintText: '请输入真实姓名',
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('取消'),
//           ),
//           TextButton(
//             onPressed: () {
//               // TODO: 实现姓名更新逻辑
//               Navigator.pop(context);
//             },
//             child: const Text('确定'),
//           ),
//         ],
//       ),
//     );
//   }

//   /// 显示性别选择器
//   void _showGenderSelector() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('选择性别'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             RadioListTile<String>(
//               title: const Text('男'),
//               value: '1',
//               groupValue: null,
//               onChanged: (value) {
//                 // TODO: 实现性别更新逻辑
//                 Navigator.pop(context);
//               },
//             ),
//             RadioListTile<String>(
//               title: const Text('女'),
//               value: '2',
//               groupValue: null,
//               onChanged: (value) {
//                 // TODO: 实现性别更新逻辑
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('取消'),
//           ),
//         ],
//       ),
//     );
//   }

//   /// 显示编辑身份证对话框
//   void _showEditIdCardDialog() {
//     final controller = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('编辑身份证号'),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(
//             labelText: '身份证号',
//             hintText: '请输入18位身份证号',
//           ),
//           keyboardType: TextInputType.text,
//           inputFormatters: [
//             FilteringTextInputFormatter.allow(RegExp(r'[0-9Xx]')),
//             LengthLimitingTextInputFormatter(18),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('取消'),
//           ),
//           TextButton(
//             onPressed: () {
//               // TODO: 实现身份证更新逻辑
//               Navigator.pop(context);
//             },
//             child: const Text('确定'),
//           ),
//         ],
//       ),
//     );
//   }

//   /// 显示编辑手机号对话框
//   void _showEditPhoneDialog() {
//     final controller = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('编辑手机号'),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(
//             labelText: '手机号',
//             hintText: '请输入11位手机号',
//           ),
//           keyboardType: TextInputType.phone,
//           inputFormatters: [
//             FilteringTextInputFormatter.digitsOnly,
//             LengthLimitingTextInputFormatter(11),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('取消'),
//           ),
//           TextButton(
//             onPressed: () {
//               // TODO: 实现手机号更新逻辑
//               Navigator.pop(context);
//             },
//             child: const Text('确定'),
//           ),
//         ],
//       ),
//     );
//   }

//   /// 显示编辑邮箱对话框
//   void _showEditEmailDialog() {
//     final controller = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('编辑邮箱'),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(
//             labelText: '邮箱地址',
//             hintText: '请输入邮箱地址',
//           ),
//           keyboardType: TextInputType.emailAddress,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('取消'),
//           ),
//           TextButton(
//             onPressed: () {
//               // TODO: 实现邮箱更新逻辑
//               Navigator.pop(context);
//             },
//             child: const Text('确定'),
//           ),
//         ],
//       ),
//     );
//   }

//   /// 拍照
//   void _takePhoto() {
//     // TODO: 实现拍照功能
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('拍照功能正在开发中')),
//     );
//   }

//   /// 从相册选择
//   void _pickFromGallery() {
//     // TODO: 实现相册选择功能
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('相册选择功能正在开发中')),
//     );
//   }

//   /// 删除头像
//   void _removeAvatar() {
//     // TODO: 实现删除头像功能
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('删除头像功能正在开发中')),
//     );
//   }

//   /// 导出资料
//   void _exportProfile() {
//     // TODO: 实现导出资料功能
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('导出资料功能正在开发中')),
//     );
//   }
// }
