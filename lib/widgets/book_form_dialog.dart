import 'dart:typed_data';

import 'package:booksbound_app/models/book_model.dart';
import 'package:booksbound_app/widgets/cached_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BookFormDialog extends StatefulWidget {
  final Book? book;
  final Function(Book, XFile?) onSubmit;

  const BookFormDialog({super.key, this.book, required this.onSubmit});

  @override
  State<BookFormDialog> createState() => _BookFormDialogState();
}

class _BookFormDialogState extends State<BookFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _genreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _isbnController = TextEditingController();
  final _ratingController = TextEditingController();

  DateTime? _selectedDate;
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _isBestseller = false;

  final List<String> _genreSuggestions = [
    'Fiction',
    'Non-Fiction',
    'Science Fiction',
    'Fantasy',
    'Mystery',
    'Thriller',
    'Romance',
    'Biography',
    'Self-Help',
    'History',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      _titleController.text = widget.book!.title;
      _authorController.text = widget.book!.author;
      _genreController.text = widget.book!.genre;
      _descriptionController.text = widget.book!.description;
      _priceController.text = widget.book!.price.toString();
      _stockController.text = widget.book!.stock.toString();
      _isbnController.text = widget.book!.isbn;
      _ratingController.text = widget.book!.rating.toString();
      _selectedDate = widget.book!.releaseDate;
      _isBestseller = widget.book!.isBestseller;
    } else {
      _selectedDate = DateTime.now();
      _stockController.text = '20';
      _ratingController.text = '4.5';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _genreController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _isbnController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 900,
      imageQuality: 65,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = pickedFile;
        _selectedImageBytes = bytes;
      });
    }
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final book = Book(
        id: widget.book?.id ?? '',
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        genre: _genreController.text.trim(),
        description: _descriptionController.text.trim(),
        coverUrl: widget.book?.coverUrl ?? '',
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        isBestseller: _isBestseller,
        releaseDate: _selectedDate!,
        isbn: _isbnController.text.trim(),
        rating: double.parse(_ratingController.text),
        reviews: widget.book?.reviews ?? [],
      );

      widget.onSubmit(book, _selectedImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.book == null ? 'Add New Book' : 'Edit Book'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Book Cover Image
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _selectedImageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
                        )
                      : widget.book?.coverUrl != null &&
                            widget.book!.coverUrl.isNotEmpty
                      ? CachedImage(
                          imageUrl: widget.book!.coverUrl,
                          width: 120,
                          height: 180,
                          borderRadius: 8,
                        )
                      : _buildPlaceholder(),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter book title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Author
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter author name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Genre with suggestions
              Autocomplete<String>(
                initialValue: TextEditingValue(text: _genreController.text),
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return _genreSuggestions.where(
                    (genre) => genre.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    ),
                  );
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                      controller.text = _genreController.text;
                      controller.addListener(() {
                        _genreController.text = controller.text;
                      });
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Genre *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter genre';
                          }
                          return null;
                        },
                      );
                    },
              ),
              const SizedBox(height: 12),

              // Price
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price *',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Available inventory
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final stock = int.tryParse(value?.trim() ?? '');
                  if (stock == null || stock < 0) {
                    return 'Enter a whole number of 0 or more';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // ISBN
              TextFormField(
                controller: _isbnController,
                decoration: const InputDecoration(
                  labelText: 'ISBN',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Rating
              TextFormField(
                controller: _ratingController,
                decoration: const InputDecoration(
                  labelText: 'Rating (0-5)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              // Release Date
              ListTile(
                title: const Text('Release Date *'),
                subtitle: Text(
                  _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Select date',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              const SizedBox(height: 12),

              // Bestseller Switch
              SwitchListTile(
                title: const Text('Bestseller'),
                value: _isBestseller,
                onChanged: (value) => setState(() => _isBestseller = value),
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submitForm, child: const Text('Save')),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
        SizedBox(height: 8),
        Text('Add Cover', style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
