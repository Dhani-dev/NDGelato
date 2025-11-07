import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/ice_cream_preview_widget.dart';
import '../providers/ice_cream_provider.dart';
import '../providers/auth_provider.dart';
// Asegúrate de importar tu modelo de helado si es necesario.
// import '../models/ice_cream_model.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _searchQuery = '';
  String _filterBase = 'All';
  String _filterFlavor = 'All';

  @override
  void initState() {
    super.initState();
    // Es mejor llamar a startListeningToIceCreams en didChangeDependencies o directamente
    // en la construcción si IceCreamProvider es inmutable, pero se mantiene aquí para seguir tu estructura.
    Provider.of<IceCreamProvider>(context, listen: false).startListeningToIceCreams();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final iceCreamProvider = Provider.of<IceCreamProvider>(context);
    final iceCreams = iceCreamProvider.iceCreams;
    final isLoading = iceCreamProvider.isLoading;

    final filteredIceCreams = iceCreams.where((ic) {
      final matchesSearch = _searchQuery.isEmpty || ic.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesBase = _filterBase == 'All' || ic.base.toLowerCase() == _filterBase.toLowerCase();
      final matchesFlavor = _filterFlavor == 'All' || ic.flavors.map((f) => f.toLowerCase()).contains(_filterFlavor.toLowerCase());
      return matchesSearch && matchesBase && matchesFlavor;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Welcome', style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'NIDDELIC', 
                  style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w900, fontSize: 18, height: 1.0)
                ),
                Text(
                  'ICE', 
                  style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w900, fontSize: 18, height: 1.0)
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.textColor),
            onPressed: () async {
              await authProvider.signOut();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Text(
              'All Ice Creams',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                    hintText: 'Search ice creams by name...',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300)
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _filterBase,
                            icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
                            items: ['All', 'Cone', 'Cup'].map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                            onChanged: (v) => setState(() => _filterBase = v ?? 'All'),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300)
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _filterFlavor,
                            icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
                            // Se asume que availableFlavors existe en IceCreamProvider
                            items: ['All', ...iceCreamProvider.availableFlavors].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                            onChanged: (v) => setState(() => _filterFlavor = v ?? 'All'),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredIceCreams.isEmpty
                    ? Center(
                        child: Text(
                          'No ice creams found!',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredIceCreams.length,
                        itemBuilder: (context, index) {
                          final iceCream = filteredIceCreams[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _IceCreamCard(
                              iceCream: iceCream,
                              previewSize: 200.0, // Mismo tamaño que en MyIceCreams
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/my_ice_creams');
          } else if (index == 2) {
            // Nota: Aquí el índice 2 probablemente debe ser la pantalla de creación si sigues el orden del nav bar (Home, My Ice Creams, Create, Profile/Orders)
            // Por ahora, se mantiene tu lógica original, pero podrías querer revisar el orden.
            Navigator.pushReplacementNamed(context, '/orders'); 
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }
}

class _IceCreamCard extends StatelessWidget {
  final dynamic iceCream;
  final double? previewSize;

  const _IceCreamCard({required this.iceCream, this.previewSize});

  @override
  Widget build(BuildContext context) {
    final preview = previewSize ?? 200.0;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.borderRadius),
                topRight: Radius.circular(AppTheme.borderRadius),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                  child: Text(
                    (iceCream.authorName != null && iceCream.authorName.isNotEmpty) ? iceCream.authorName[0].toUpperCase() : 'U',
                    style: TextStyle(color: AppTheme.accentColor),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        iceCream.authorName ?? 'You',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            iceCream.base == 'Cone' ? Icons.icecream : Icons.local_cafe,
                            color: AppTheme.textColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              iceCream.name ?? 'Untitled Ice Cream',
                              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '\$${(iceCream.price ?? 0.0).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: IceCreamPreviewWidget(
              base: iceCream.base ?? 'Cone',
              flavors: iceCream.flavors ?? [],
              toppings: iceCream.toppings ?? [],
              size: preview,
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flavors:',
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    ...((iceCream.flavors ?? []).take(3)).map<Widget>(
                      (flavor) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          flavor,
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    if ((iceCream.flavors ?? []).length > 3)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+${(iceCream.flavors ?? []).length - 3}',
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Toppings:',
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    ...((iceCream.toppings ?? []).take(4)).map<Widget>(
                      (topping) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          topping,
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: AppTheme.secondaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    if ((iceCream.toppings ?? []).length > 4)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+${(iceCream.toppings ?? []).length - 4}',
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: AppTheme.secondaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


