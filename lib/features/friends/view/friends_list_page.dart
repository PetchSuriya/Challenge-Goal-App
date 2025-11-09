import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controller/friends_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/friends_service.dart';
import 'dart:math' as math;

class FriendsListPage extends ConsumerStatefulWidget {
  const FriendsListPage({super.key});

  @override
  ConsumerState<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsSummaryCard extends StatelessWidget {
  final int totalFriends;
  final int activeFriends;
  final int mutualGoals;
  final VoidCallback? onAdd;

  const _FriendsSummaryCard({
    required this.totalFriends,
    required this.activeFriends,
    required this.mutualGoals,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.purple.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.people, color: Colors.white),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Friends Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              if (onAdd != null) ...[
                ElevatedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.person_add_alt_1, size: 18),
                  label: const Text('Add Friend'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 6,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Total Friends',
                  value: totalFriends.toString(),
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Active Now',
                  value: activeFriends.toString(),
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Mutual Goals',
                  value: mutualGoals.toString(),
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _FriendsListPageState extends ConsumerState<FriendsListPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dialogSearchController = TextEditingController();
  late TabController _tabController;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTab = _tabController.index;
      });
    });
    // Load friends when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(friendsControllerProvider.notifier).loadFriends();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dialogSearchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendsState = ref.watch(friendsControllerProvider);
    final pendingCount = friendsState.pendingRequests.length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              pinned: true,
              snap: false,
              elevation: 0,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => context.go(AppConstants.homeRoute),
              ),
              title: const Text(
                'Friends',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.person_add, color: Colors.blue.shade600),
                  onPressed: _onAddFriend,
                  tooltip: 'Add Friend',
                ),
                const SizedBox(width: 8),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.blue.shade700,
                    unselectedLabelColor: Colors.grey.shade600,
                    indicatorColor: Colors.blue.shade700,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    tabs: [
                      const Tab(text: 'Friends'),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Requests'),
                            if (pendingCount > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade500,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$pendingCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Tab(text: 'Discover'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildFriendsTab(friendsState),
            _buildRequestsTab(friendsState),
            _buildDiscoverTab(friendsState),
          ],
        ),
      ),
    );
  }

  // Tab 1: Friends Tab
  Widget _buildFriendsTab(FriendsState state) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(friendsControllerProvider.notifier).loadFriends();
      },
      child: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _buildErrorWidget(state.error!)
              : state.friends.isEmpty
                  ? _buildEmptyFriendsWidget()
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _FriendsSummaryCard(
                          totalFriends: state.friends.length,
                          activeFriends: _calculateActiveFriends(state.friends),
                          mutualGoals: 0,
                          onAdd: _onAddFriend,
                        ),
                        const SizedBox(height: 20),
                        ...state.friends.map((friend) => _buildModernFriendCard(friend)),
                      ],
                    ),
    );
  }

  // Tab 2: Requests Tab
  Widget _buildRequestsTab(FriendsState state) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(friendsControllerProvider.notifier).loadFriends();
      },
      child: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.pendingRequests.isEmpty
              ? _buildEmptyRequestsWidget()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade50, Colors.red.shade50],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.notifications_active, color: Colors.orange.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${state.pendingRequests.length} pending request${state.pendingRequests.length > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...state.pendingRequests.map((request) => _buildRequestCard(request)),
                  ],
                ),
    );
  }

  // Tab 3: Discover Tab
  Widget _buildDiscoverTab(FriendsState state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey.shade600),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for friends...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: (query) async {
                    if (query.trim().isNotEmpty) {
                      await ref.read(friendsControllerProvider.notifier).searchUsers(query);
                    }
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_searchController.text.trim().isNotEmpty) {
                    await ref.read(friendsControllerProvider.notifier).searchUsers(_searchController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: const Text('Search', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Search Results
        if (state.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (state.searchResults.isEmpty && _searchController.text.trim().isEmpty)
          _buildDiscoverEmptyState()
        else if (state.searchResults.isEmpty)
          _buildNoResultsWidget()
        else
          ...state.searchResults.map((user) => _buildSearchResultCard(user)),
      ],
    );
  }

  int _calculateActiveFriends(List<User> friends) {
    // Simulate active friends (in real app, check last activity)
    return (friends.length * 0.6).round();
  }

  Widget _buildModernFriendCard(User user) {
    final isOnline = math.Random(user.id).nextBool(); // Simulate online status
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  user.username[0].toUpperCase(),
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green.shade500,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (isOnline)
                      Text(
                        'Active now',
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else if (user.email != null)
                      Flexible(
                        child: Text(
                          user.email!,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'view') {
                context.go('/friends/profile/${user.id}');
              } else if (value == 'unfriend') {
                _showUnfriendDialog(user);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20, color: Colors.blue.shade600),
                    const SizedBox(width: 12),
                    const Text('View Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'unfriend',
                child: Row(
                  children: [
                    Icon(Icons.person_remove, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Unfriend', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(User user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.orange.shade100,
                child: Text(
                  user.username[0].toUpperCase(),
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Wants to be your friend',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _acceptFriendRequest(user),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _declineFriendRequest(user),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsList(FriendsState state) {
    if (state.friends.isEmpty) {
      return _buildEmptyFriendsWidget();
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: state.friends.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final user = state.friends[index];
        return _buildModernFriendCard(user);
      },
    );
  }

  Widget _buildSearchResults(List<User> searchResults) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      shrinkWrap: true,
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final user = searchResults[index];
        return _buildSearchResultCard(user);
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.green.shade600, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildFriendCard(User user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.green.shade100,
          child: Text(
            user.username[0].toUpperCase(),
            style: TextStyle(
              color: Colors.green.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          user.username,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: user.email != null
            ? Text(
                user.email!,
                style: TextStyle(color: Colors.grey.shade600),
              )
            : null,
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
          onSelected: (value) {
            if (value == 'unfriend') {
              _showUnfriendDialog(user);
            } else if (value == 'view') {
              // Navigate to friend's profile
              context.go('/friends/profile/${user.id}');
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.person, size: 20),
                  SizedBox(width: 8),
                  Text('View Profile'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'unfriend',
              child: Row(
                children: [
                  Icon(Icons.person_remove, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Unfriend', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigate to friend's profile page
          context.go('/friends/profile/${user.id}');
        },
      ),
    );
  }

  Widget _buildPendingRequestCard(User user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.orange.shade100,
          child: Text(
            user.username[0].toUpperCase(),
            style: TextStyle(
              color: Colors.orange.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          user.username,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: const Text('Wants to be your friend'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Accept button
            ElevatedButton(
              onPressed: () => _acceptFriendRequest(user),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                minimumSize: const Size(60, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Accept'),
            ),
            const SizedBox(width: 8),
            // Decline button
            OutlinedButton(
              onPressed: () => _declineFriendRequest(user),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                minimumSize: const Size(60, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Decline'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(User user) {
    String? buttonText;
    Color? buttonColor;
    VoidCallback? onPressed;

    switch (user.status) {
      case 'accepted':
        buttonText = 'Friends';
        buttonColor = Colors.green;
        break;
      case 'pending':
        buttonText = 'Pending';
        buttonColor = Colors.orange;
        break;
      case 'requested_by_them':
        buttonText = 'Accept';
        buttonColor = Colors.blue;
        onPressed = () => _acceptFriendRequest(user);
        break;
      default:
        buttonText = 'Add Friend';
        buttonColor = Colors.green;
        onPressed = () => _sendFriendRequest(user);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.blue.shade100,
          child: Text(
            user.username[0].toUpperCase(),
            style: TextStyle(
              color: Colors.blue.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          user.username,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: user.email != null
            ? Text(
                user.email!,
                style: TextStyle(color: Colors.grey.shade600),
              )
            : null,
        trailing: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(72, 36),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Text(buttonText),
        ),
      ),
    );
  }

  void _onAddFriend() {
    final TextEditingController searchCtrl = _dialogSearchController;
    ref.read(friendsControllerProvider.notifier).clearSearch();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Consumer(
          builder: (context, ref, child) {
            final results = ref.watch(friendsControllerProvider).searchResults;
            final isLoading = ref.watch(friendsControllerProvider).isLoading;
            final pendingRequests = ref.watch(friendsControllerProvider).pendingRequests;
            
            Future<void> performSearch() async {
              final query = searchCtrl.text.trim();
              if (query.isEmpty) {
                ref.read(friendsControllerProvider.notifier).clearSearch();
                return;
              }
              await ref.read(friendsControllerProvider.notifier).searchUsers(query);
            }
            
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              title: const Text('Find a friend'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: searchCtrl,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Type a friend name',
                      filled: true,
                      fillColor: Colors.blue.shade50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade300),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search, color: Colors.blue.shade600),
                        onPressed: performSearch,
                      ),
                    ),
                    onSubmitted: (_) => performSearch(),
                  ),
                  const SizedBox(height: 12),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    )
                  else if (results.isEmpty && searchCtrl.text.trim().isNotEmpty)
                    Container(
                      alignment: Alignment.centerLeft,
                      child: const Text('No results'),
                    )
                  else if (results.isNotEmpty)
                    SizedBox(
                      height: 260,
                      width: double.maxFinite,
                      child: _buildSearchResults(results),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    ref.read(friendsControllerProvider.notifier).clearSearch();
                    Navigator.of(dialogCtx).pop();
                  },
                  child: const Text('Close'),
                  style: TextButton.styleFrom(foregroundColor: Colors.black87),
                ),
                TextButton(
                  onPressed: performSearch,
                  child: const Text('Search'),
                  style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogCtx).pop();
                    _showIncomingRequests();
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Text('Requests'),
                      if (pendingRequests.isNotEmpty)
                        Positioned(
                          right: -8,
                          top: -4,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  style: TextButton.styleFrom(foregroundColor: Colors.blueGrey),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showIncomingRequests() {
    final pending = ref.read(friendsControllerProvider).pendingRequests;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blue.shade200, Colors.purple.shade100]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person_add, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'People who added you',
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (pending.isNotEmpty) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${pending.length}',
                      style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.6,
            ),
            child: SizedBox(
              width: double.maxFinite,
              child: pending.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text('No incoming friend requests', textAlign: TextAlign.center),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final req = pending[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.purple.shade100,
                                  child: Text(req.username[0].toUpperCase(), style: TextStyle(color: Colors.purple.shade700, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        req.username,
                                        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (req.email != null && req.email!.isNotEmpty)
                                        Text(
                                          req.email!,
                                          style: TextStyle(color: Colors.black54, fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final ok = await ref.read(friendsControllerProvider.notifier).acceptFriendRequest(req.id);
                                      if (!mounted) return;
                                      Navigator.of(ctx).pop();
                                      if (ok) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Accepted ${req.username}')),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade600,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Text('Accept', style: TextStyle(fontSize: 14)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      final ok = await ref.read(friendsControllerProvider.notifier).unfriend(req.id);
                                      if (!mounted) return;
                                      Navigator.of(ctx).pop();
                                      if (ok) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Declined ${req.username}')),
                                        );
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red.shade600,
                                      side: BorderSide(color: Colors.red.shade100),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Text('Decline', style: TextStyle(fontSize: 14)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemCount: pending.length,
                  ),
              ),
            ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
              style: TextButton.styleFrom(foregroundColor: Colors.black87),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyFriendsWidget() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 60),
        Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.people_outline,
                  size: 60,
                  color: Colors.blue.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No friends yet',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Start building your network!\nSearch and add friends to begin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _onAddFriend,
                icon: const Icon(Icons.person_add),
                label: const Text('Find Friends'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyRequestsWidget() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 60),
        Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_none,
                  size: 60,
                  color: Colors.orange.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No pending requests',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You don\'t have any friend requests\nat the moment.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiscoverEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search,
              size: 60,
              color: Colors.purple.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Discover Friends',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Use the search bar above to find\nfriends by username.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsWidget() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with a different username',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(friendsControllerProvider.notifier).clearError();
              ref.read(friendsControllerProvider.notifier).loadFriends();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _sendFriendRequest(User user) async {
    final success = await ref
        .read(friendsControllerProvider.notifier)
        .sendFriendRequest(user.id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Friend request sent to ${user.username}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _acceptFriendRequest(User user) async {
    final success = await ref
        .read(friendsControllerProvider.notifier)
        .acceptFriendRequest(user.id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.username} is now your friend!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _declineFriendRequest(User user) async {
    // For now, declining is the same as unfriending
    final success = await ref
        .read(friendsControllerProvider.notifier)
        .unfriend(user.id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Friend request from ${user.username} declined'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showUnfriendDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Unfriend'),
        content: Text('Are you sure you want to unfriend ${user.username}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await ref
                  .read(friendsControllerProvider.notifier)
                  .unfriend(user.id);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${user.username} has been unfriended'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Unfriend'),
          ),
        ],
      ),
    );
  }
}