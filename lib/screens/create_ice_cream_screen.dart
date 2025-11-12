import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ice_cream_model.dart';
import '../providers/ice_cream_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/ice_cream_preview_widget.dart';

class CreateIceCreamScreen extends StatefulWidget {
  const CreateIceCreamScreen({super.key});

  @override
  State<CreateIceCreamScreen> createState() => _CreateIceCreamScreenState();
}

class _CreateIceCreamScreenState extends State<CreateIceCreamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<String> _selectedFlavors = [];
  final List<String> _selectedToppings = [];
  String _base = 'Cone';
  static const int maxFlavors = 3;
  static const int maxToppings = 4;
  bool _isLoading = false;

  final Map<String, dynamic> flavorData = {
    'Strawberry': {'color': Colors.pink.shade400, 'abbr': 'S'},
    'Chocolate': {'color': Colors.brown.shade700, 'abbr': 'C'},
    'Vanilla': {'color': Colors.yellow.shade200, 'abbr': 'V'},
    'Mint': {'color': Colors.teal.shade300, 'abbr': 'M'},
    'Blueberry': {'color': Colors.indigo.shade300, 'abbr': 'B'},
    'Mango': {
      'color': Colors.orange.shade400,
      'abbr': 'A',
    },
    'Pistachio': {'color': Colors.green.shade400, 'abbr': 'P'},
    'Cookies & Cream': {'color': Colors.grey.shade400, 'abbr': 'K'},
  };

  final Map<String, String> toppingIcons = {
    'Sprinkles': '🌈',
    'Cherry': '🍒',
    'Choc Chips': '🍫',
    'Whipped Cream': '☁️',
    'Caramel': '🍯',
    'Nuts': '🌰',
    'Candy Bears': '🐻',
    'Cookie': '🍪',
  };

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  late IceCreamProvider iceCreamProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    iceCreamProvider = Provider.of<IceCreamProvider>(context);
  }

  void _toggleFlavor(String flavor) {
    setState(() {
      if (_selectedFlavors.contains(flavor)) {
        _selectedFlavors.remove(flavor);
      } else {
        if (_selectedFlavors.length < maxFlavors) {
          _selectedFlavors.add(flavor);
        } else {
          _showSnackbar('You can select up to $maxFlavors flavors');
        }
      }
    });
  }

  void _toggleTopping(String topping) {
    setState(() {
      if (_selectedToppings.contains(topping)) {
        _selectedToppings.remove(topping);
      } else {
        if (_selectedToppings.length < maxToppings) {
          _selectedToppings.add(topping);
        } else {
          _showSnackbar('You can select up to $maxToppings toppings');
        }
      }
    });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFlavors.isEmpty) {
      _showSnackbar(
        'Please select at least one flavor.',
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _isLoading = true);

    try {
      const basePrice = 0.00; // Precio base
      final flavorPrice = _selectedFlavors.length * 2.00; // $2.00 por sabor
      final toppingPrice = _selectedToppings.length * 1.00; // $1.00 por topping
      final totalPrice = basePrice + flavorPrice + toppingPrice;

      final iceCream = IceCream(
        name: _nameController.text,
        price: totalPrice,
        base: _base,
        authorId: authProvider.userModel?.uid ?? '',
        authorName: authProvider.userModel?.displayName ?? 'Unknown',
        flavors: _selectedFlavors,
        toppings: _selectedToppings,
      );

      await iceCreamProvider.createIceCream(iceCream);

      if (mounted) {
        _showSnackbar('Ice cream created successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Build Your Ice Cream',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide =
              constraints.maxWidth >
              900;

          return Form(
            key: _formKey,
            child: isWide
                ? SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _CustomSectionCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Name Your Creation',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.attach_money,
                                                size: 20,
                                                color: AppTheme.primaryColor,
                                              ),
                                              Text(
                                                ((_selectedFlavors.length *
                                                            2.00) +
                                                        (_selectedToppings
                                                                .length *
                                                            1.00))
                                                    .toStringAsFixed(2),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(
                                                      color:
                                                          AppTheme.primaryColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                        hintText: 'e.g. Rainbow Delight',
                                        filled: true,
                                        fillColor: AppTheme.backgroundColor,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a name';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              _CustomSectionCard(
                                title: 'Choose Your Base',
                                child: Row(
                                  children: [
                                    _BaseOption(
                                      label: 'Cone',
                                      icon: Icons.icecream,
                                      isSelected: _base == 'Cone',
                                      onTap: () =>
                                          setState(() => _base = 'Cone'),
                                    ),
                                    const SizedBox(width: 16),
                                    _BaseOption(
                                      label: 'Cup',
                                      icon: Icons.local_cafe,
                                      isSelected: _base == 'Cup',
                                      onTap: () =>
                                          setState(() => _base = 'Cup'),
                                    ),
                                  ],
                                ),
                              ),
                              _CustomSectionCard(
                                title: 'Select Flavors (Max $maxFlavors)',
                                child: Wrap(
                                  spacing: 22,
                                  runSpacing: 22,
                                  children: iceCreamProvider.availableFlavors
                                      .map((flavor) {
                                        final data =
                                            flavorData[flavor] ??
                                            {'color': Colors.grey, 'abbr': '?'};
                                        return _FlavorChip(
                                          flavor: flavor,
                                          color: data['color'] as Color,
                                          abbr: data['abbr'] as String,
                                          isSelected: _selectedFlavors.contains(
                                            flavor,
                                          ),
                                          onTap: () => _toggleFlavor(flavor),
                                        );
                                      })
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          flex: 1,
                          child: _CustomSectionCard(
                            title: 'Preview',
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
                            child: Column(
                              children: [
                                IceCreamPreviewWidget(
                                  base: _base,
                                  flavors: _selectedFlavors,
                                  toppings: _selectedToppings,
                                  size:
                                      200,
                                  flavorData:
                                      flavorData,
                                  toppingIcons:
                                      toppingIcons,
                                ),

                                const SizedBox(height: 32),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _submitForm,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : Text(
                                            'Save Ice Cream',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _CustomSectionCard(
                                title: 'Add Toppings (Max $maxToppings)',
                                child: Wrap(
                                  spacing: 22,
                                  runSpacing: 22,
                                  children: iceCreamProvider.availableToppings
                                      .map((topping) {
                                        return _ToppingChip(
                                          topping: topping,
                                          icon: toppingIcons[topping] ?? '•',
                                          isSelected: _selectedToppings
                                              .contains(topping),
                                          onTap: () => _toggleTopping(topping),
                                        );
                                      })
                                      .toList(),
                                ),
                              ),

                              
                              _CustomSectionCard(
                                title:
                                    'Your Selection (${_selectedFlavors.length}/$maxFlavors)',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Flavors:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: _selectedFlavors
                                          .map(
                                            (flavor) => _SelectionChip(
                                              label: flavor,
                                              color: AppTheme.primaryColor,
                                            ),
                                          )
                                          .toList(),
                                    ),

                                    const SizedBox(height: 16),

                                    
                                    Text(
                                      'Toppings (${_selectedToppings.length}/$maxToppings):',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: _selectedToppings
                                          .map(
                                            (topping) => _SelectionChip(
                                              label: topping,
                                              color: AppTheme.secondaryColor,
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      bottom: 80,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CustomSectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Name Your Creation',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.attach_money,
                                          size: 20,
                                          color: AppTheme.primaryColor,
                                        ),
                                        Text(
                                          ((_selectedFlavors.length * 2.00) +
                                                  (_selectedToppings.length *
                                                      1.00))
                                              .toStringAsFixed(2),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                color: AppTheme.primaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  hintText: 'e.g. Rainbow Delight',
                                  filled: true,
                                  fillColor: AppTheme.backgroundColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a name';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        _CustomSectionCard(
                          title: 'Choose Your Base',
                          child: Row(
                            children: [
                              _BaseOption(
                                label: 'Cone',
                                icon: Icons.icecream,
                                isSelected: _base == 'Cone',
                                onTap: () => setState(() => _base = 'Cone'),
                              ),
                              const SizedBox(width: 16),
                              _BaseOption(
                                label: 'Cup',
                                icon: Icons.local_cafe,
                                isSelected: _base == 'Cup',
                                onTap: () => setState(() => _base = 'Cup'),
                              ),
                            ],
                          ),
                        ),

                        _CustomSectionCard(
                          title: 'Select Flavors (Max $maxFlavors)',
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: iceCreamProvider.availableFlavors.map((
                              flavor,
                            ) {
                              final data =
                                  flavorData[flavor] ??
                                  {'color': Colors.grey, 'abbr': '?'};
                              return _FlavorChip(
                                flavor: flavor,
                                color: data['color'] as Color,
                                abbr: data['abbr'] as String,
                                isSelected: _selectedFlavors.contains(flavor),
                                onTap: () => _toggleFlavor(flavor),
                              );
                            }).toList(),
                          ),
                        ),

                        _CustomSectionCard(
                          title: 'Preview',
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            children: [
                              // --- Helado Preview ---
                              IceCreamPreviewWidget(
                                base: _base,
                                flavors: _selectedFlavors,
                                toppings: _selectedToppings,
                                size:
                                    200,
                                flavorData:
                                    flavorData,
                                toppingIcons:
                                    toppingIcons,
                              ),

                              const SizedBox(height: 32),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _submitForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : Text(
                                          'Save Ice Cream',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge!
                                              .copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        _CustomSectionCard(
                          title: 'Add Toppings (Max $maxToppings)',
                          child: SizedBox(
                            width: double
                                .infinity,
                            child: Wrap(
                              alignment: WrapAlignment
                                  .center,
                              spacing: 12,
                              runSpacing: 12,
                              children: iceCreamProvider.availableToppings.map((
                                topping,
                              ) {
                                return _ToppingChip(
                                  topping: topping,
                                  icon: toppingIcons[topping] ?? '•',
                                  isSelected: _selectedToppings.contains(
                                    topping,
                                  ),
                                  onTap: () => _toggleTopping(topping),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        _CustomSectionCard(
                          title:
                              'Your Selection (${_selectedFlavors.length}/$maxFlavors)',
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Flavors:',
                                  style: Theme.of(context).textTheme.bodyLarge!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _selectedFlavors
                                      .map(
                                        (flavor) => _SelectionChip(
                                          label: flavor,
                                          color: AppTheme.primaryColor,
                                        ),
                                      )
                                      .toList(),
                                ),

                                const SizedBox(height: 16),

                                Text(
                                  'Toppings (${_selectedToppings.length}/$maxToppings):',
                                  style: Theme.of(context).textTheme.bodyLarge!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _selectedToppings
                                      .map(
                                        (topping) => _SelectionChip(
                                          label: topping,
                                          color: AppTheme.secondaryColor,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/my_ice_creams');
          } else if (index == 2) {
            // already on create
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }
}

class _CustomSectionCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsets padding;

  const _CustomSectionCard({
    this.title,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class _BaseOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _BaseOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.primaryColor,
                size: 30,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: isSelected ? Colors.white : AppTheme.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlavorChip extends StatelessWidget {
  final String flavor;
  final Color color;
  final String abbr;
  final bool isSelected;
  final VoidCallback onTap;

  const _FlavorChip({
    required this.flavor,
    required this.color,
    required this.abbr,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: isSelected
                  ? Border.all(color: Colors.pinkAccent, width: 4)
                  : null,
            ),
            child: Center(
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 28)
                  : Text(
                      abbr,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            flavor,
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ToppingChip extends StatelessWidget {
  final String topping;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToppingChip({
    required this.topping,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        width: 80,
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              topping,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionChip extends StatelessWidget {
  final String label;
  final Color color;

  const _SelectionChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
