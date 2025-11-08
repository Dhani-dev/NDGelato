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
    Provider.of<IceCreamProvider>(
      context,
      listen: false,
    ).startListeningToIceCreams();
  }

  // Widget para la sección de búsqueda y filtros (separado para la organización)
  Widget _buildFilterControls(BuildContext context, IceCreamProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Búsqueda
          TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.search,
                color: AppTheme.primaryColor,
              ),
              hintText: 'Search ice creams by name...',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filtros Dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _filterBase,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: AppTheme.primaryColor,
                      ),
                      items: ['All', 'Cone', 'Cup']
                          .map(
                            (b) => DropdownMenuItem(
                              value: b,
                              child: Text(b),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _filterBase = v ?? 'All'),
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
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _filterFlavor,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: AppTheme.primaryColor,
                      ),
                      // Se asume que availableFlavors existe en IceCreamProvider
                      items: ['All', ...provider.availableFlavors]
                          .map(
                            (f) => DropdownMenuItem(
                              value: f,
                              child: Text(f),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _filterFlavor = v ?? 'All'),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final iceCreamProvider = Provider.of<IceCreamProvider>(context);
    final iceCreams = iceCreamProvider.iceCreams;
    final isLoading = iceCreamProvider.isLoading;

    final filteredIceCreams = iceCreams.where((ic) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          ic.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesBase =
          _filterBase == 'All' ||
          ic.base.toLowerCase() == _filterBase.toLowerCase();
      final matchesFlavor =
          _filterFlavor == 'All' ||
          ic.flavors
              .map((f) => f.toLowerCase())
              .contains(_filterFlavor.toLowerCase());
      return matchesSearch && matchesBase && matchesFlavor;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Welcome',
          style: TextStyle(
            color: AppTheme.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SizedBox(
              height: 50,
              child: Image.asset('assets/logo_gelato.png', fit: BoxFit.contain),
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
      // --- Cambio clave: Usar ListView como cuerpo para que todo se deslice ---
      body: ListView(
        // Desactivamos el padding automático si es necesario, pero lo dejamos por defecto
        // crossAxisAlignment: CrossAxisAlignment.start, // No aplicable a ListView
        children: [
          // Título
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0, top: 8.0),
            child: Text(
              'All Ice Creams',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
          ),

          // Controles de Búsqueda y Filtro (Ahora dentro del scroll)
          _buildFilterControls(context, iceCreamProvider),
          const SizedBox(height: 16),

          // Contenido principal de la lista de helados
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredIceCreams.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'No ice creams found!',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    )
                  // --- Implementación Responsive con LayoutBuilder y GridView ---
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        // Determina el número de columnas basado en el ancho disponible
                        int crossAxisCount;
                        if (constraints.maxWidth > 1200) {
                          crossAxisCount = 4; // Pantalla muy ancha (Desktop)
                        } else if (constraints.maxWidth > 800) {
                          crossAxisCount = 3; // Tablet horizontal / Web ancha
                        } else if (constraints.maxWidth > 500) {
                          crossAxisCount = 2; // Tablet vertical / Teléfono grande horizontal
                        } else {
                          crossAxisCount = 1; // Teléfono móvil (diseño original)
                        }

                        // El GridView.builder requiere que su padre sea Expanded o tenga una altura definida,
                        // pero como estamos dentro de un ListView principal, debemos usar ShrinkWrap
                        // y desactivar el scroll del GridView.
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GridView.builder(
                            shrinkWrap: true, // Esto permite que el GridView tome solo el espacio necesario en el ListView
                            physics: const NeverScrollableScrollPhysics(), // Desactiva el scroll propio del GridView
                            itemCount: filteredIceCreams.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              // Ajustamos la relación de aspecto para que la tarjeta no sea demasiado alta.
                              // Se necesita una altura mínima para el contenido (preview + detalles)
                              childAspectRatio: 0.75, // Ajuste para 1 columna (largo) -> 0.75 (más cuadrado)
                            ),
                            itemBuilder: (context, index) {
                              final iceCream = filteredIceCreams[index];
                              // Ajustamos el tamaño de la previsualización basado en el número de columnas
                              double previewSize = crossAxisCount == 1 ? 200.0 : 120.0;
                              return _IceCreamCard(
                                iceCream: iceCream,
                                previewSize: previewSize,
                              );
                            },
                          ),
                        );
                      },
                    ),
          const SizedBox(height: 16), // Espacio al final del grid
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/my_ice_creams');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/create_ice_cream'); // Asumiendo que el índice 2 es Crear
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }
}

// El widget _IceCreamCard (manteniendo tu lógica actual)
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
                    (iceCream.authorName != null &&
                            iceCream.authorName.isNotEmpty)
                        ? iceCream.authorName[0].toUpperCase()
                        : 'U',
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
                            iceCream.base == 'Cone'
                                ? Icons.icecream
                                : Icons.local_cafe,
                            color: AppTheme.textColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              iceCream.name ?? 'Untitled Ice Cream',
                              style: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(fontWeight: FontWeight.bold),
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
          
          // Preview del Helado
          SizedBox(
            height: preview, // Ajusta la altura de la preview
            child: Center(
              child: IceCreamPreviewWidget(
                base: iceCream.base ?? 'Cone',
                flavors: iceCream.flavors ?? [],
                toppings: iceCream.toppings ?? [],
                size: preview * 0.9, // Ajusta el tamaño real del dibujo dentro del contenedor
              ),
            ),
          ),
          
          // Detalles de Sabores y Toppings
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sabores
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
                    ...((iceCream.flavors ?? []).take(2)).map<Widget>( // Reducimos a 2 para más columnas
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
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                        ),
                      ),
                    ),
                    if ((iceCream.flavors ?? []).length > 2)
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
                          '+${(iceCream.flavors ?? []).length - 2}',
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
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
                // Toppings
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
                    ...((iceCream.toppings ?? []).take(2)).map<Widget>( // Reducimos a 2 para más columnas
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
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
                                color: AppTheme.secondaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                        ),
                      ),
                    ),
                    if ((iceCream.toppings ?? []).length > 2)
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
                          '+${(iceCream.toppings ?? []).length - 2}',
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
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