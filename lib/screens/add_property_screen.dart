import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart';

// NEW: Import the services
import 'package:sora_app/services/cloudinary_service.dart';
import 'package:sora_app/services/firestore_service.dart';

// New: Custom Input Formatter for number with commas
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const separator = ',';

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Check if the new value is just a number
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String newText = newValue.text.replaceAll(separator, '');
    if (newText.length > 1 && newText.startsWith('0')) {
      newText = newText.substring(1);
    }
    
    final int selectionIndex = newValue.selection.end;
    if (newText.length < 4) {
      return newValue.copyWith(
          text: newText, selection: TextSelection.collapsed(offset: newText.length));
    }

    final buffer = StringBuffer();
    final parts = <String>[];
    int start = newText.length % 3;
    if (start != 0) {
      parts.add(newText.substring(0, start));
    }
    for (int i = start; i < newText.length; i += 3) {
      parts.add(newText.substring(i, i + 3));
    }

    buffer.write(parts.join(separator));

    final newString = buffer.toString();
    final newSelectionOffset = newValue.text.length > newString.length ?
        selectionIndex - (newValue.text.length - newString.length) :
        selectionIndex + (newString.length - newValue.text.length);

    return newValue.copyWith(
      text: newString,
      selection: TextSelection.collapsed(offset: newSelectionOffset),
    );
  }
}

class AddPropertyScreen extends StatefulWidget {
  final AuthService authService;

  const AddPropertyScreen({Key? key, required this.authService}) : super(key: key);

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  late CommonWidgets commonWidgets;
  int _currentStep = 0;
  bool _isSubmitting = false; // NEW: State variable for submission status

  // Form fields data
  String _propertyType = ''; // Residential, Commercial, Industrial, Land
  String _listingType = ''; // For Sale, For Rent, For Lease
  String _selectedCounty = '';

  // New controllers for the editable dropdown fields
  final TextEditingController _townController = TextEditingController();
  final TextEditingController _localityMtaaController = TextEditingController(); // Now a text field controller

  // County Search Field related controllers and state
  final TextEditingController _countyController = TextEditingController();
  final FocusNode _countyFocusNode = FocusNode();
  List<String> _filteredCounties = [];

  // General Property Details
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  String _sizeUnit = 'sqft'; // sqft, sqm, acres
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _yearBuiltController = TextEditingController();
  final TextEditingController _plotNumberController = TextEditingController();
  final TextEditingController _titleDeedController = TextEditingController();

  // New: Dynamic Property Detail field
  String _selectedPropertyDetail = '';
  final Map<String, List<String>> _propertyDetailOptions = {
    'Residential': ['Bungalow', 'Mansion', 'Villa', 'Apartment', 'Townhouse', 'Condo', 'Duplex', 'Farmhouse', 'Other'],
    'Commercial': ['Office Space', 'Retail Space', 'Restaurant', 'Hotel', 'Warehouse', 'Other'],
    'Industrial': ['Factory', 'Warehouse', 'Plant', 'Godown', 'Other'],
    'Land': ['Agricultural', 'Commercial', 'Residential', 'Industrial', 'Mixed-use', 'Other'],
  };

  // Residential Specific Fields
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _floorsController = TextEditingController();
  String _propertyCondition = '';
  final Map<String, bool> _selectedHeatingTypes = {
    'Solar': false,
    'Electric': false,
    'Gas': false,
    'Other': false,
  };
  // NEW: Controller for "Other" heating type
  final TextEditingController _otherHeatingController = TextEditingController();
  final Map<String, bool> _selectedCoolingTypes = {
    'Electric': false,
    'Solar': false,
    'Central Air': false,
    'Other': false,
  };
  // NEW: Controller for "Other" cooling type
  final TextEditingController _otherCoolingController = TextEditingController();
  String _roofingType = '';
  String _flooringType = '';

  // Commercial Specific Fields
  final TextEditingController _commercialTypeController = TextEditingController();
  final TextEditingController _occupancyController = TextEditingController();
  final TextEditingController _leaseTermsController = TextEditingController();
  final TextEditingController _businessTypeController = TextEditingController();

  // Industrial Specific Fields
  final TextEditingController _industrialTypeController = TextEditingController();
  final TextEditingController _powerCapacityController = TextEditingController();
  final TextEditingController _accessRoadsController = TextEditingController();

  // Land Specific Fields
  final TextEditingController _zoningController = TextEditingController();
  final TextEditingController _utilitiesController = TextEditingController();
  final TextEditingController _landFeaturesController = TextEditingController();

  // Checkbox states for features and amenities
  // Separate maps for features based on property type
  Map<String, bool> _residentialFeatures = {
    'Swimming Pool': false,
    'Garden': false,
    'Balcony': false,
    'Gym': false,
    'Parking': false,
    'Security System': false,
    'Pet Friendly': false,
    'Furnished': false,
    'Air Conditioning': false,
    'Fireplace': false,
    'Dishwasher': false,
    'Washer/Dryer': false,
    'Built-in Wardrobes': false,
    'En-suite Bathroom': false,
    'Walk-in Closet': false,
    'Smart Home System': false,
    'Solar Panels': false,
    'Backup Generator': false,
    'Gated Residence': false,
    'Servant Quarters': false,
    'Borehole': false,
  };

  Map<String, bool> _commercialFeatures = {
    'Parking': false,
    'Security System': false,
    'Air Conditioning': false,
    'Backup Generator': false,
    'Lifts': false,
    '24/7 Access': false,
    'CCTV': false,
    'Kitchenette': false,
    'Restrooms': false,
    'Reception Area': false,
  };

  Map<String, bool> _industrialFeatures = {
    'Parking': false,
    'Security System': false,
    'Loading Docks': false,
    'High Ceilings': false,
    'Backup Generator': false,
    'Three-Phase Power': false,
    'Crane Access': false,
    'Office Space': false,
  };

  // Amenities for Residential only
  Map<String, bool> _residentialAmenities = {
    'Church': false,
    'Mosque': false,
    'Schools': false,
    'Hospitals': false,
    'Shopping Malls': false,
    'Parks': false,
    'Public Transport': false,
    'Restaurants': false,
    'Supermarkets': false,
    'Gyms': false,
    'Banks': false,
    'Pharmacies': false,
    'Police Station': false,
    'Community Center': false,
    'Recreational Facilities': false,
    'Playgrounds': false,
    'Golf Course': false,
    'Temple': false,
  };

  // Contact Information
  final TextEditingController _contactPersonController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();
  final TextEditingController _contactWhatsappController = TextEditingController();

  // NEW: Store XFile objects instead of URLs
  List<XFile> _coverImages = [];
  List<XFile> _additionalImages = [];

  // Location data (simplified for example)
  final List<String> _kenyanCounties = [
    'Baringo', 'Bomet', 'Bungoma', 'Busia', 'Elgeyo-Marakwet', 'Embu', 'Garissa', 'Homa Bay', 'Isiolo', 'Kajiado',
    'Kakamega', 'Kericho', 'Kiambu', 'Kilifi', 'Kirinyaga', 'Kisii', 'Kisumu', 'Kitui', 'Kwale', 'Laikipia',
    'Lamu', 'Machakos', 'Makueni', 'Mandera', 'Marsabit', 'Meru', 'Migori', 'Mombasa', 'Murang\'a', 'Nairobi',
    'Nakuru', 'Nandi', 'Narok', 'Nyamira', 'Nyandarua', 'Nyeri', 'Samburu', 'Siaya', 'Taita-Taveta', 'Tana River',
    'Tharaka-Nithi', 'Trans-Nzoia', 'Turkana', 'Uasin Gishu', 'Vihiga', 'Wajir', 'West Pokot'
  ];

  final Map<String, List<String>> _countyTowns = {
    'Baringo': ['Kabarnet'],
    'Bomet': ['Bomet'],
    'Bungoma': ['Bungoma'],
    'Busia': ['Busia'],
    'Elgeyo-Marakwet': ['Iten'],
    'Embu': ['Embu'],
    'Garissa': ['Garissa'],
    'Homa Bay': ['Homa Bay'],
    'Isiolo': ['Isiolo'],
    'Kajiado': ['Kajiado'],
    'Kakamega': ['Kakamega'],
    'Kericho': ['Kericho'],
    'Kiambu': ['Thika', 'Limuru', 'Ruaka', 'Kiambu Town'],
    'Kilifi': ['Malindi', 'Watamu', 'Kilifi Town'],
    'Kirinyaga': ['Kerugoya'],
    'Kisii': ['Kisii'],
    'Kisumu': ['Kisumu CBD', 'Milimani', 'Tom Mboya'],
    'Kitui': ['Kitui'],
    'Kwale': ['Ukunda', 'Msambweni', 'Lunga Lunga'],
    'Laikipia': ['Rumuruti'],
    'Lamu': ['Lamu'],
    'Machakos': ['Machakos Town', 'Athi River', 'Mlolongo'],
    'Makueni': ['Wote'],
    'Mandera': ['Mandera'],
    'Marsabit': ['Marsabit'],
    'Meru': ['Meru'],
    'Migori': ['Migori'],
    'Mombasa': ['Mombasa CBD', 'Nyali', 'Diani', 'Ukunda'],
    'Murang\'a': ['Murang\'a'],
    'Nairobi': ['Nairobi CBD', 'Westlands', 'Karen', 'Gigiri', 'Kilimani', 'Lavington', 'Runda', 'Muthaiga', 'Embakasi', 'Syokimau'],
    'Nakuru': ['Nakuru CBD', 'Lanet', 'Njoro'],
    'Nandi': ['Kapsabet'],
    'Narok': ['Narok'],
    'Nyamira': ['Nyamira'],
    'Nyandarua': ['Ol Kalou'],
    'Nyeri': ['Nyeri'],
    'Samburu': ['Maralal'],
    'Siaya': ['Siaya'],
    'Taita-Taveta': ['Wundanyi'],
    'Tana River': ['Hola'],
    'Tharaka-Nithi': ['Kathwana'],
    'Trans-Nzoia': ['Kitale'],
    'Turkana': ['Lodwar'],
    'Uasin Gishu': ['Eldoret CBD', 'Langas', 'Kapsoya'],
    'Vihiga': ['Mbale'],
    'Wajir': ['Wajir'],
    'West Pokot': ['Kapenguria'],
  };

  // NEW: Instantiate the services
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);
    // Initialize with all counties
    _filteredCounties = _kenyanCounties;
    
    // Add listener to the county text field to filter suggestions
    _countyController.addListener(_filterCounties);
    
    // Listen for focus changes to hide suggestions when field is unfocused
    _countyFocusNode.addListener(() {
      if (!_countyFocusNode.hasFocus) {
        // Delay to allow for tap on a list item to register
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              _filteredCounties = []; // Hide the list
              // If the entered text doesn't match a county, clear it.
              if (!_kenyanCounties.contains(_countyController.text)) {
                _countyController.clear();
                _selectedCounty = '';
              }
            });
          }
        });
      }
    });
  }

  // Method to filter the list of counties based on user input
  void _filterCounties() {
    final query = _countyController.text.toLowerCase();
    setState(() {
      _filteredCounties = _kenyanCounties.where((county) {
        return county.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Method to pick images
  Future<void> _pickImage({required bool isCoverPhoto, required bool isMultiple}) async {
    final ImagePicker picker = ImagePicker();
    if (isMultiple) {
      final List<XFile> selectedImages = await picker.pickMultiImage();
      if (selectedImages.isNotEmpty) {
        setState(() {
          if (isCoverPhoto) {
            _coverImages.addAll(selectedImages.take(1)); // Take only the first one
            // If more than one selected, show a snackbar
            if (selectedImages.length > 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Only one cover photo can be selected. The first image was used.'),
                ),
              );
            }
          } else {
            // Filter out images that would exceed the maxImages count
            final availableSlots = 26 - _additionalImages.length;
            _additionalImages.addAll(selectedImages.take(availableSlots));
            if (selectedImages.length > availableSlots) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Maximum of 26 additional images allowed. Only the first $availableSlots images were added.'),
                ),
              );
            }
          }
        });
      }
    } else {
      final XFile? selectedImage = await picker.pickImage(source: ImageSource.gallery);
      if (selectedImage != null) {
        setState(() {
          if (isCoverPhoto) {
            _coverImages.clear();
            _coverImages.add(selectedImage);
          } else {
            // Check if adding this image would exceed the limit
            if (_additionalImages.length < 26) {
              _additionalImages.add(selectedImage);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Maximum of 26 additional images allowed. Please remove an image before adding a new one.'),
                ),
              );
            }
          }
        });
      }
    }
  }

  // Method to remove a specific image
  void _removeImage(XFile imageToRemove, {required bool isCoverPhoto}) {
    setState(() {
      if (isCoverPhoto) {
        _coverImages.remove(imageToRemove);
      } else {
        _additionalImages.remove(imageToRemove);
      }
    });
  }

  // Method to reset property-specific data when the property type changes
  void _resetPropertySpecificData() {
    _bedroomsController.clear();
    _bathroomsController.clear();
    _floorsController.clear();
    _propertyCondition = '';
    _roofingType = '';
    _flooringType = '';
    _selectedHeatingTypes.updateAll((key, value) => false);
    _selectedCoolingTypes.updateAll((key, value) => false);
    _otherHeatingController.clear(); // NEW: Clear "Other" field
    _otherCoolingController.clear(); // NEW: Clear "Other" field

    _commercialTypeController.clear();
    _occupancyController.clear();
    _leaseTermsController.clear();
    _businessTypeController.clear();

    _industrialTypeController.clear();
    _powerCapacityController.clear();
    _accessRoadsController.clear();

    _zoningController.clear();
    _utilitiesController.clear();
    _landFeaturesController.clear();

    // Reset feature and amenity selections
    _residentialFeatures.updateAll((key, value) => false);
    _commercialFeatures.updateAll((key, value) => false);
    _industrialFeatures.updateAll((key, value) => false);
    _residentialAmenities.updateAll((key, value) => false);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _priceController.dispose();
    _sizeController.dispose();
    _descriptionController.dispose();
    _yearBuiltController.dispose();
    _plotNumberController.dispose();
    _titleDeedController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _floorsController.dispose();
    _otherHeatingController.dispose(); // NEW: Dispose new controller
    _otherCoolingController.dispose(); // NEW: Dispose new controller
    _commercialTypeController.dispose();
    _occupancyController.dispose();
    _leaseTermsController.dispose();
    _businessTypeController.dispose();
    _industrialTypeController.dispose();
    _powerCapacityController.dispose();
    _accessRoadsController.dispose();
    _zoningController.dispose();
    _utilitiesController.dispose();
    _landFeaturesController.dispose();
    _contactPersonController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    _contactWhatsappController.dispose();
    _townController.dispose();
    _localityMtaaController.dispose();
    _countyController.dispose();
    _countyFocusNode.dispose();
    super.dispose();
  }

  // NEW: Updated submit form logic
  void _submitForm() async {
    if (_isSubmitting) return; // Prevent double submission

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 1. Upload images to Cloudinary
      String? coverImageUrl;
      if (_coverImages.isNotEmpty) {
        coverImageUrl = await _cloudinaryService.uploadImage(_coverImages.first);
      }

      final additionalImageUrls = await _cloudinaryService.uploadMultipleImages(_additionalImages);

      if (coverImageUrl == null && _coverImages.isNotEmpty) {
        throw Exception('Failed to upload cover image.');
      }
      
      // 2. Prepare data for Firestore
      final Map<String, dynamic> propertyData = {
        'propertyType': _propertyType,
        'listingType': _listingType,
        'location': {
          'county': _selectedCounty,
          'town': _townController.text,
          'locality': _localityMtaaController.text,
        },
        'title': _addressController.text,
        'price': _priceController.text.replaceAll(',', ''), // Remove commas before storing
        'size': _sizeController.text,
        'sizeUnit': _sizeUnit,
        'description': _descriptionController.text,
        'yearBuilt': _yearBuiltController.text,
        'plotNumber': _plotNumberController.text,
        'titleDeed': _titleDeedController.text,
        'coverImageUrl': coverImageUrl,
        'additionalImageUrls': additionalImageUrls,
        'contactInfo': {
          'contactPerson': _contactPersonController.text,
          'phone': _contactPhoneController.text,
          'email': _contactEmailController.text,
          'whatsapp': _contactWhatsappController.text,
        },
      };

      // Add type-specific details
      switch (_propertyType) {
        case 'Residential':
          propertyData['residentialDetails'] = {
            'propertyDetail': _selectedPropertyDetail,
            'bedrooms': _bedroomsController.text,
            'bathrooms': _bathroomsController.text,
            'floors': _floorsController.text,
            'propertyCondition': _propertyCondition,
            'heatingTypes': _selectedHeatingTypes.entries.where((e) => e.value).map((e) => e.key).toList(),
            'coolingTypes': _selectedCoolingTypes.entries.where((e) => e.value).map((e) => e.key).toList(),
            'roofingType': _roofingType,
            'flooringType': _flooringType,
          };
          propertyData['features'] = _residentialFeatures.entries.where((e) => e.value).map((e) => e.key).toList();
          propertyData['amenities'] = _residentialAmenities.entries.where((e) => e.value).map((e) => e.key).toList();
          break;
        case 'Commercial':
          propertyData['commercialDetails'] = {
            'propertyDetail': _selectedPropertyDetail,
            'occupancy': _occupancyController.text,
            'leaseTerms': _leaseTermsController.text,
            'businessType': _businessTypeController.text,
          };
          propertyData['features'] = _commercialFeatures.entries.where((e) => e.value).map((e) => e.key).toList();
          break;
        case 'Industrial':
          propertyData['industrialDetails'] = {
            'propertyDetail': _selectedPropertyDetail,
            'powerCapacity': _powerCapacityController.text,
            'accessRoads': _accessRoadsController.text,
          };
          propertyData['features'] = _industrialFeatures.entries.where((e) => e.value).map((e) => e.key).toList();
          break;
        case 'Land':
          propertyData['landDetails'] = {
            'propertyDetail': _selectedPropertyDetail,
            'zoning': _zoningController.text,
            'utilities': _utilitiesController.text,
            'landFeatures': _landFeaturesController.text,
          };
          break;
      }
      
      // 3. Store data in Firestore
      final success = await _firestoreService.addProperty(propertyData);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Property listing submitted successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        throw Exception('Failed to add property to Firestore.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Submission failed: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // --- Widgets for each step ---
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormSection(
          'Property & Listing Type',
          Icons.home,
          [
            _buildSubSectionTitle('Property Type'),
            _buildPropertyTypeSelection(),
            const SizedBox(height: 10),
            if (_propertyType.isNotEmpty) _buildPropertyDetailDropdown(),
            const SizedBox(height: 20),
            _buildSubSectionTitle('Listing Type'),
            _buildListingTypeSelection(),
          ],
        ),
        _buildFormSection(
          'Location Details',
          Icons.location_on,
          [
            _buildSearchableCountyDropdown(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    'Town',
                    _townController.text,
                    _countyTowns[_selectedCounty] ?? [],
                    (String? newValue) {
                      setState(() {
                        _townController.text = newValue!;
                        _localityMtaaController.clear();
                      });
                    },
                    icon: Icons.location_on,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    _localityMtaaController, // Now a text field controller
                    'Locality/Mtaa',
                    'e.g., Upper Hill',
                    icon: Icons.place,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormSection(
          'Basic Property Details',
          Icons.info,
          [
            _buildTextField(
              _addressController,
              'Property Title',
              'e.g., 5 bedroom mansion in Karen, Nairobi',
              maxLines: 3,
              icon: Icons.location_city,
              widthFactor: 1.0,
              maxLength: 100, // Character limit for title
            ),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(_priceController, 'Price (KSH)', 'e.g., 25,000,000', keyboardType: TextInputType.number, icon: Icons.attach_money, inputFormatters: [FilteringTextInputFormatter.digitsOnly, ThousandsSeparatorInputFormatter()]),
                ),
                // NEW: Conditional Price Label
                if (_listingType == 'For Rent')
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 18.0),
                    child: Text(
                      '/month',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                if (_listingType == 'For Lease')
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 18.0),
                    child: Text(
                      '/year',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSizeField(),
                ),
              ],
            ),
            _buildTextField(
              _descriptionController,
              'Property Description',
              'Provide a detailed description of the property',
              maxLines: 4,
              icon: Icons.description,
              widthFactor: 1.0,
              maxLength: 1000, // Character limit for description
            ),
            // Replaced the text field with a year picker
            if (_propertyType != 'Land')
              _buildYearPickerField(),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_propertyType == 'Residential') _buildResidentialDetails(),
        if (_propertyType == 'Commercial') _buildCommercialDetails(),
        if (_propertyType == 'Industrial') _buildIndustrialDetails(),
        if (_propertyType == 'Land') _buildLandDetails(),

        // Features & Amenities are hidden for land
        if (_propertyType != 'Land' && _propertyType.isNotEmpty)
          _buildFormSection(
            'Features & Amenities',
            Icons.star,
            [
              _buildFeaturesSection(),
              if (_propertyType == 'Residential') ...[
                const SizedBox(height: 24),
                _buildAmenitiesSection(),
              ]
            ],
          ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormSection(
          'Contact Information',
          Icons.contact_phone,
          [
            _buildTextField(_contactPersonController, 'Contact Person Name', 'e.g., John Doe', icon: Icons.person, widthFactor: 1.0),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(_contactPhoneController, 'Phone Number', 'e.g., +254712345678', keyboardType: TextInputType.phone, icon: Icons.phone),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(_contactWhatsappController, 'WhatsApp Number', 'e.g., +254712345678', keyboardType: TextInputType.phone, icon: Icons.chat),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildTextField(_contactEmailController, 'Email Address', 'e.g., john@example.com', keyboardType: TextInputType.emailAddress, icon: Icons.email, widthFactor: 1.0),
          ],
        ),
        _buildFormSection(
          'Property Images',
          Icons.image,
          [
            _buildImageUploadSection(),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: commonWidgets.buildAppBar(),
      endDrawer: commonWidgets.buildDrawer(),
      body: Column(
        children: [
          // Sticky Step Progress Indicator
          _buildStickyStepProgressIndicator(),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section (now scrolls with content)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF0A66C2), const Color(0xFF1E90FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0A66C2).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Property Listing',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Fill in the details to list your property.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Main Content Area based on step
                  if (_currentStep == 0) _buildStep1(),
                  if (_currentStep == 1) _buildStep2(),
                  if (_currentStep == 2) _buildStep3(),
                  if (_currentStep == 3) _buildStep4(),

                  const SizedBox(height: 32),

                  // Navigation Buttons (now scrollable with content)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep > 0)
                        SizedBox(
                          width: 150,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0A66C2),
                              side: const BorderSide(color: Color(0xFF0A66C2), width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _isSubmitting ? null : () {
                              setState(() {
                                _currentStep--;
                              });
                            },
                            child: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      const Spacer(),
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : () {
                            if (_currentStep < 3) {
                              setState(() {
                                _currentStep++;
                              });
                            } else {
                              _submitForm();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF0A66C2),
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 3,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : Text(
                                  _currentStep < 3 ? 'Next' : 'Submit Listing',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Sticky Step Progress Indicator Widget ---
  Widget _buildStickyStepProgressIndicator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: List.generate(4, (index) {
              bool isActive = index <= _currentStep;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 4),
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF0A66C2) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepLabel('1. Property & Location', 0),
              _buildStepLabel('2. Details', 1),
              _buildStepLabel('3. Features', 2),
              _buildStepLabel('4. Contact & Images', 3),
            ],
          ),
          const Divider(height: 24, thickness: 1, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStepLabel(String text, int index) {
    bool isActive = index == _currentStep;
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? const Color(0xFF0A66C2) : Colors.grey[600],
          fontSize: 12,
        ),
      ),
    );
  }

  // --- Helper methods for building form sections and fields ---

  Widget _buildFormSection(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF0A66C2), size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0A66C2),
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSubSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    List<TextInputFormatter>? inputFormatters,
    double? widthFactor,
    Widget? suffixIcon,
    FocusNode? focusNode,
    int? maxLength, // NEW: Added maxLength parameter
  }) {
    return Container(
      width: widthFactor != null ? MediaQuery.of(context).size.width * widthFactor : null,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        maxLength: maxLength, // NEW: Applied maxLength
        maxLengthEnforcement: MaxLengthEnforcement.enforced, // NEW: Added enforcement
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF0A66C2), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          counterText: maxLength != null ? '${controller.text.length}/$maxLength' : null,
        ),
        onChanged: (text) {
          if (maxLength != null) {
            setState(() {}); // Rebuild to update the counter
          }
        },
      ),
    );
  }
  
  // New method for searchable county dropdown
  Widget _buildSearchableCountyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          _countyController,
          'County',
          'Search for a county',
          icon: Icons.location_city,
          focusNode: _countyFocusNode,
        ),
        if (_countyFocusNode.hasFocus && _filteredCounties.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredCounties.length,
              itemBuilder: (context, index) {
                final county = _filteredCounties[index];
                return ListTile(
                  title: Text(county),
                  onTap: () {
                    setState(() {
                      _selectedCounty = county;
                      _countyController.text = county;
                      _townController.clear();
                      _localityMtaaController.clear();
                      _filteredCounties = []; // Hide the list
                    });
                    _countyFocusNode.unfocus(); // Dismiss keyboard
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String currentValue, List<String> items, Function(String?) onChanged, {IconData? icon, double? widthFactor}) {
    return Container(
      width: widthFactor != null ? MediaQuery.of(context).size.width * widthFactor : null,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: currentValue.isNotEmpty ? currentValue : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF0A66C2), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        hint: Text('Select $label'),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  // New method for dynamic property detail dropdown
  Widget _buildPropertyDetailDropdown() {
    if (_propertyType.isEmpty) {
      return const SizedBox.shrink(); // Hide the dropdown if no property type is selected
    }

    final List<String> items = _propertyDetailOptions[_propertyType] ?? [];
    return _buildDropdownField(
      'Property Detail',
      _selectedPropertyDetail,
      items,
      (String? newValue) {
        setState(() {
          _selectedPropertyDetail = newValue!;
        });
      },
      icon: Icons.category,
      widthFactor: 1.0,
    );
  }

  Widget _buildPropertyTypeSelection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildPropertyTypeButton('Residential', Icons.house),
            _buildPropertyTypeButton('Commercial', Icons.business),
            _buildPropertyTypeButton('Industrial', Icons.factory),
            _buildPropertyTypeButton('Land', Icons.landscape),
          ],
        ),
        if (_propertyType.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              'Selected: $_propertyType',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A66C2)),
            ),
          ),
      ],
    );
  }

  Widget _buildPropertyTypeButton(String type, IconData icon) {
    bool isSelected = _propertyType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (_propertyType != type) {
              _resetPropertySpecificData();
            }
            _propertyType = type;
            _selectedPropertyDetail = ''; // Reset property detail when type changes
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0A66C2) : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF0A66C2) : Colors.grey[400]!,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : const Color(0xFF0A66C2)),
              const SizedBox(height: 8),
              Text(
                type,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListingTypeSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildListingTypeButton('For Sale', Icons.attach_money),
        _buildListingTypeButton('For Rent', Icons.house_siding),
        _buildListingTypeButton('For Lease', Icons.handshake),
      ],
    );
  }

  Widget _buildListingTypeButton(String type, IconData icon) {
    bool isSelected = _listingType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _listingType = type;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0A66C2) : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF0A66C2) : Colors.grey[400]!,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : const Color(0xFF0A66C2)),
              const SizedBox(height: 8),
              Text(
                type,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSizeField() {
    return _buildTextField(
      _sizeController,
      'Size',
      'e.g., 1500',
      keyboardType: TextInputType.number,
      icon: Icons.square_foot,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, ThousandsSeparatorInputFormatter()],
      suffixIcon: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sizeUnit,
          onChanged: (String? newValue) {
            setState(() {
              _sizeUnit = newValue!;
            });
          },
          items: <String>['sqft', 'sqm', 'acres']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildYearPickerField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _yearBuiltController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Year Built',
          hintText: 'Select a year',
          prefixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF0A66C2), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        onTap: () {
          _showYearPicker(context);
        },
      ),
    );
  }

  void _showYearPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final int currentYear = DateTime.now().year;
        final int startYear = 1900;
        final List<int> years = List.generate(currentYear - startYear + 1, (index) => currentYear - index);

        return AlertDialog(
          title: const Text('Select Year'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5, // Reduced width
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.0,
              ),
              itemCount: years.length,
              itemBuilder: (BuildContext context, int index) {
                final int year = years[index];
                final bool isSelected = _yearBuiltController.text == year.toString();
                return InkWell(
                  onTap: () {
                    setState(() {
                      _yearBuiltController.text = year.toString();
                    });
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0A66C2) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      year.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildResidentialDetails() {
    return _buildFormSection(
      'Residential Specifics',
      Icons.house,
      [
        Row(
              children: [
                Expanded(
                  child: _buildTextField(_bedroomsController, 'Bedrooms', 'e.g., 3', keyboardType: TextInputType.number, icon: Icons.bed, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(_bathroomsController, 'Bathrooms', 'e.g., 2', keyboardType: TextInputType.number, icon: Icons.bathtub, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                ),
              ],
            ),
        _buildDropdownField(
          'Property Condition',
          _propertyCondition,
          ['New', 'Used', 'Under Renovation'],
          (String? newValue) {
            setState(() { _propertyCondition = newValue!; });
          },
          icon: Icons.build,
          widthFactor: 1.0,
        ),
        _buildTextField(_floorsController, 'Number of Floors', 'e.g., 2', keyboardType: TextInputType.number, icon: Icons.layers, inputFormatters: [FilteringTextInputFormatter.digitsOnly], widthFactor: 1.0),
        _buildSubSectionTitle('Heating Type'),
        _buildCheckboxGrid(_selectedHeatingTypes),
        // NEW: Conditionally show "Other" text field
        if (_selectedHeatingTypes['Other']!)
          _buildTextField(
            _otherHeatingController,
            'Specify Other Heating Type',
            'e.g., Wood Stove',
            icon: Icons.thermostat,
            widthFactor: 1.0,
          ),
        const SizedBox(height: 20),
        _buildSubSectionTitle('Cooling Type'),
        _buildCheckboxGrid(_selectedCoolingTypes),
        // NEW: Conditionally show "Other" text field
        if (_selectedCoolingTypes['Other']!)
          _buildTextField(
            _otherCoolingController,
            'Specify Other Cooling Type',
            'e.g., Evaporative Cooler',
            icon: Icons.ac_unit,
            widthFactor: 1.0,
          ),
        const SizedBox(height: 20),
        _buildDropdownField(
          'Roofing Type',
          _roofingType,
          ['Concrete', 'Tiles', 'Shingles', 'Metal', 'Thatch', 'Other'],
          (String? newValue) {
            setState(() { _roofingType = newValue!; });
          },
          icon: Icons.roofing,
          widthFactor: 1.0,
        ),
        _buildDropdownField(
          'Flooring Type',
          _flooringType,
          ['Tiles', 'Wood', 'Carpet', 'Laminate', 'Concrete', 'Other'],
          (String? newValue) {
            setState(() { _flooringType = newValue!; });
          },
          icon: Icons.texture,
          widthFactor: 1.0,
        ),
      ],
    );
  }

  Widget _buildCommercialDetails() {
    return _buildFormSection(
      'Commercial Specifics',
      Icons.business,
      [
        _buildTextField(_occupancyController, 'Occupancy', 'e.g., 80%', keyboardType: TextInputType.number, icon: Icons.people, inputFormatters: [FilteringTextInputFormatter.digitsOnly], widthFactor: 1.0),
        _buildTextField(_leaseTermsController, 'Lease Terms', 'e.g., 5 years', icon: Icons.calendar_today, widthFactor: 1.0),
        _buildTextField(_businessTypeController, 'Business Type', 'e.g., Retail, Office', icon: Icons.work, widthFactor: 1.0),
      ],
    );
  }

  Widget _buildIndustrialDetails() {
    return _buildFormSection(
      'Industrial Specifics',
      Icons.factory,
      [
        _buildTextField(_powerCapacityController, 'Power Capacity (KVA)', 'e.g., 500', keyboardType: TextInputType.number, icon: Icons.power, inputFormatters: [FilteringTextInputFormatter.digitsOnly], widthFactor: 1.0),
        _buildTextField(_accessRoadsController, 'Access Roads', 'e.g., Tarmac, Murram', icon: Icons.traffic, widthFactor: 1.0),
      ],
    );
  }

  Widget _buildLandDetails() {
    return _buildFormSection(
      'Land Specifics',
      Icons.landscape,
      [
        _buildTextField(_zoningController, 'Zoning', 'e.g., Residential, Commercial', icon: Icons.map, widthFactor: 1.0),
        _buildTextField(_utilitiesController, 'Utilities Available', 'e.g., Water, Electricity, Sewer', icon: Icons.electrical_services, widthFactor: 1.0),
        _buildTextField(_landFeaturesController, 'Land Features', 'e.g., Flat, Hilly, Near River', icon: Icons.terrain, widthFactor: 1.0),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    Map<String, bool> featuresMap;
    switch (_propertyType) {
      case 'Residential':
        featuresMap = _residentialFeatures;
        break;
      case 'Commercial':
        featuresMap = _commercialFeatures;
        break;
      case 'Industrial':
        featuresMap = _industrialFeatures;
        break;
      default:
        featuresMap = {};
        break;
    }

    if (featuresMap.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubSectionTitle('Features'),
        _buildCheckboxGrid(featuresMap),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    if (_propertyType != 'Residential') {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubSectionTitle('Amenities Nearby'),
        _buildCheckboxGrid(_residentialAmenities),
      ],
    );
  }

  Widget _buildCheckboxGrid(Map<String, bool> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 6.0,
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        String item = items.keys.elementAt(index);
        return _buildCheckbox(item, items[item]!, (bool? value) {
          setState(() {
            items[item] = value!;
          });
        });
      },
    );
  }

  Widget _buildCheckbox(String title, bool value, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(
            scale: 0.9,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF0A66C2),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 4.0),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubSectionTitle('Cover Image (Max 1)'),
        _buildImageUploadContainer(isCoverPhoto: true),
        const SizedBox(height: 20),
        _buildSubSectionTitle('Additional Images (Max 26)'),
        _buildImageUploadContainer(isCoverPhoto: false),
      ],
    );
  }

  Widget _buildImageUploadContainer({required bool isCoverPhoto}) {
    List<XFile> images = isCoverPhoto ? _coverImages : _additionalImages;
    int maxImages = isCoverPhoto ? 1 : 26;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ...images.map((image) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb
                        ? FutureBuilder<Uint8List>(
                            future: image.readAsBytes(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                return Image.memory(
                                  snapshot.data!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                );
                              } else {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey[200],
                                  child: const Center(child: CircularProgressIndicator()),
                                );
                              }
                            },
                          )
                        : Image.file(
                            File(image.path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        _removeImage(image, isCoverPhoto: isCoverPhoto);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              )).toList(),
              if (images.length < maxImages)
                GestureDetector(
                  onTap: () {
                    // Use a single image picker for cover photo, multi for additional images
                    _pickImage(isCoverPhoto: isCoverPhoto, isMultiple: !isCoverPhoto);
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: Icon(Icons.add_a_photo, color: Colors.grey[600], size: 40),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${images.length} / $maxImages images uploaded',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
