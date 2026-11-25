import '../models/product.dart';

/// Sample catalogue inspired by what you find in Algerian pharmacies.
/// Prices (DA) and stock are fictional - replace with the REST API later.
const mockProducts = <Product>[
  Product(
    id: 'p01', name: 'Doliprane 1000 mg', brand: 'Sanofi', form: 'Box of 8 tablets',
    price: 150, quantity: 48, category: ProductCategory.painFever,
    description: 'Paracetamol-based analgesic and antipyretic. Relieves mild to moderate pain (headache, toothache, body aches) and reduces fever. Respect the maximum daily dose and the interval between two doses.',
  ),
  Product(
    id: 'p02', name: 'Paracétamol 500 mg', brand: 'Saidal', form: 'Box of 20 tablets',
    price: 90, quantity: 120, category: ProductCategory.painFever,
    description: 'Algerian-made generic paracetamol for pain and fever in adults and children over 6 years. An affordable everyday essential for the home pharmacy.',
  ),
  Product(
    id: 'p03', name: 'Dafalgan 500 mg Effervescent', brand: 'UPSA', form: '16 effervescent tablets',
    price: 280, quantity: 34, category: ProductCategory.painFever,
    description: 'Fast-acting paracetamol in effervescent form, dissolved in a glass of water. Suitable for pain and fever, easier to take when swallowing tablets is difficult.',
  ),
  Product(
    id: 'p04', name: 'Brufen 400 mg', brand: 'Abbott', form: 'Box of 30 tablets',
    price: 340, quantity: 3, category: ProductCategory.painFever,
    description: 'Ibuprofen anti-inflammatory used for pain, fever, period cramps and inflammatory conditions. Take with food. Not recommended for people with stomach ulcers.',
  ),
  Product(
    id: 'p05', name: 'Voltarène Emulgel 1%', brand: 'Haleon', form: 'Tube of 50 g',
    price: 560, quantity: 25, category: ProductCategory.painFever,
    description: 'Anti-inflammatory gel for local relief of muscle and joint pain, sprains, bruises and back pain. For external use only, on unbroken skin.',
  ),
  Product(
    id: 'p06', name: 'Strepsils Miel-Citron', brand: 'Reckitt', form: 'Box of 24 lozenges',
    price: 420, quantity: 60, category: ProductCategory.coldFlu,
    description: 'Antiseptic lozenges that soothe sore throats and mouth irritation. Let the lozenge dissolve slowly in the mouth.',
  ),
  Product(
    id: 'p07', name: 'Augmentin 1 g', brand: 'GSK', form: 'Box of 12 tablets',
    price: 980, quantity: 14, category: ProductCategory.antibiotics, requiresPrescription: true,
    description: 'Amoxicillin / clavulanic acid antibiotic prescribed for bacterial infections (ENT, respiratory, urinary, skin). Complete the full course prescribed by your doctor.',
  ),
  Product(
    id: 'p08', name: 'Spasfon', brand: 'Teva', form: 'Box of 30 tablets',
    price: 390, quantity: 22, category: ProductCategory.digestive,
    description: 'Antispasmodic that relieves painful cramps of the stomach, intestines, bladder and uterus.',
  ),
  Product(
    id: 'p09', name: 'Smecta', brand: 'Ipsen', form: 'Box of 12 sachets',
    price: 260, quantity: 40, category: ProductCategory.digestive,
    description: 'Natural clay powder used in acute diarrhea and for stomach and intestinal discomfort. Dilute the sachet in half a glass of water.',
  ),
  Product(
    id: 'p10', name: 'Maalox', brand: 'Sanofi', form: 'Box of 40 chewable tablets',
    price: 420, quantity: 0, category: ProductCategory.digestive,
    description: 'Antacid that relieves heartburn and stomach acidity. Chew the tablet well, one to two hours after meals.',
  ),
  Product(
    id: 'p11', name: 'Gaviscon Sachets', brand: 'Reckitt', form: 'Box of 24 sachets',
    price: 790, quantity: 15, category: ProductCategory.digestive,
    description: 'Fast relief of acid reflux and heartburn. Forms a protective layer on top of stomach contents.',
  ),
  Product(
    id: 'p12', name: 'Supradyn Intensia', brand: 'Bayer', form: '30 effervescent tablets',
    price: 1250, quantity: 18, category: ProductCategory.vitamins,
    description: 'Multivitamin and mineral complex to fight fatigue and support energy, concentration and immunity during periods of increased needs.',
  ),
  Product(
    id: 'p13', name: 'Magné B6', brand: 'Sanofi', form: 'Box of 50 tablets',
    price: 640, quantity: 27, category: ProductCategory.vitamins,
    description: 'Magnesium and vitamin B6 supplement for magnesium deficiency, nervousness, tiredness and muscle cramps.',
  ),
  Product(
    id: 'p14', name: 'Vitamine C 500 mg', brand: 'UPSA', form: 'Box of 30 chewable tablets',
    price: 480, quantity: 4, category: ProductCategory.vitamins,
    description: 'Vitamin C for tiredness and to support natural defences, especially during winter.',
  ),
  Product(
    id: 'p15', name: 'Sensibio H2O Micellar Water', brand: 'Bioderma', form: 'Bottle of 250 ml',
    price: 2450, oldPrice: 2800, quantity: 12, category: ProductCategory.skinCare,
    description: 'Gentle micellar water that cleanses the face and removes make-up without rubbing. Suitable for sensitive skin.',
  ),
  Product(
    id: 'p16', name: 'Anthelios UVMune 400 SPF50+', brand: 'La Roche-Posay', form: 'Tube of 50 ml',
    price: 3350, quantity: 9, category: ProductCategory.skinCare,
    description: 'Very high protection facial sunscreen against UVA, UVB and long UVA. Fragrance-free, non-sticky finish.',
  ),
  Product(
    id: 'p17', name: 'Gel Lavant Doux', brand: 'Mustela', form: 'Bottle of 500 ml',
    price: 2200, quantity: 14, category: ProductCategory.babyCare,
    description: 'Tear-free gentle cleansing gel for baby hair and body, from birth. Dermatologically tested.',
  ),
  Product(
    id: 'p18', name: 'Hydra Bébé Face Cream', brand: 'Mustela', form: 'Tube of 40 ml',
    price: 1650, oldPrice: 1850, quantity: 7, category: ProductCategory.babyCare,
    description: "Moisturising cream that protects baby's delicate face skin from dryness and cold weather.",
  ),
  Product(
    id: 'p19', name: 'Bétadine Dermique 10%', brand: 'Mylan', form: 'Bottle of 125 ml',
    price: 380, quantity: 30, category: ProductCategory.firstAid,
    description: 'Antiseptic solution for cleaning and disinfecting wounds, cuts and skin before minor procedures.',
  ),
  Product(
    id: 'p20', name: 'Sérum Physiologique', brand: 'Gilbert', form: 'Box of 20 vials of 5 ml',
    price: 180, quantity: 75, category: ProductCategory.firstAid,
    description: 'Sterile saline single-dose vials for cleansing eyes and nose, including in babies and children.',
  ),
  Product(
    id: 'p21', name: 'Surgical Face Masks', brand: 'MediCare', form: 'Box of 50 masks',
    price: 350, quantity: 200, category: ProductCategory.firstAid,
    description: '3-layer disposable surgical masks with elastic ear loops. Breathable and comfortable for daily use.',
  ),
  Product(
    id: 'p22', name: 'Digital Thermometer', brand: 'Microlife', form: 'Flexible tip, 10 s reading',
    price: 750, quantity: 25, category: ProductCategory.devices,
    description: 'Accurate digital thermometer with a flexible tip, memory of the last measurement and an end-of-measurement beep.',
  ),
  Product(
    id: 'p23', name: 'Omron M2 Basic', brand: 'Omron', form: 'Upper-arm blood pressure monitor',
    price: 7800, oldPrice: 8500, quantity: 6, category: ProductCategory.devices,
    description: 'Clinically validated automatic blood pressure monitor with irregular heartbeat detection and a large, easy-to-read display.',
  ),
  Product(
    id: 'p24', name: 'Accu-Chek Instant', brand: 'Roche', form: 'Meter kit + 10 test strips',
    price: 4900, quantity: 2, category: ProductCategory.devices,
    description: 'Blood glucose meter with fast results in 4 seconds and a simple, clear display. Includes lancing device and strips.',
  ),
];
