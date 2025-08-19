import 'package:flutter/material.dart';
import '../../models/address_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/constants.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({Key? key}) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _authService = AuthService();

  List<Address> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final data = await _authService.getAddresses();
    if (data != null) {
      setState(() {
        _addresses = data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddressForm({Address? address}) {
    final _formKey = GlobalKey<FormState>();
    final _addressController = TextEditingController(text: address?.address ?? '');
    String _localDeliveryType = address?.deliveryType ?? 'incity';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 16,
                right: 16,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildInput('Адрес', _addressController),
                    SizedBox(height: 16),
                    RadioListTile(
                      value: 'incity',
                      groupValue: _localDeliveryType,
                      title: Text('Внутри города'),
                      onChanged: (val) => setModalState(() => _localDeliveryType = val!),
                    ),
                    RadioListTile(
                      value: 'intercity',
                      groupValue: _localDeliveryType,
                      title: Text('Межгород'),
                      onChanged: (val) => setModalState(() => _localDeliveryType = val!),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await _authService.updateOrCreateAddress({
                            'address': _addressController.text,
                            'delivery_type': _localDeliveryType,
                          }, id: address?.id);

                          if (success) {
                            Navigator.pop(context);
                            await _loadAddresses();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Адрес сохранён')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Ошибка при сохранении')),
                            );
                          }
                        }
                      },
                      child: Text('Сохранить'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Адрес доставки')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Адрес доставки')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: _addresses.isEmpty
            ? Center(
          child: ElevatedButton.icon(
            icon: Icon(Icons.add),
            label: Text('Добавить адрес'),
            onPressed: () => _showAddressForm(),
          ),
        )
            : ListView.builder(
          itemCount: _addresses.length,
          itemBuilder: (context, index) {
            final addr = _addresses[index];
            return ListTile(
              title: Text(addr.address),
              subtitle: Text(addr.deliveryType == 'intercity' ? 'Межгород' : 'Внутри города'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _showAddressForm(address: addr),
              ),
            );
          },
        ),
      ),
    );
  }
}
