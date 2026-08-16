enum WordRelation { synonym, antonym, partOf, function, causeEffect }

class WordEntry {
  final String word;
  final String category;
  const WordEntry(this.word, this.category);
}

class WordPair {
  final String a;
  final String b;
  final WordRelation relation;
  const WordPair(this.a, this.b, this.relation);
}

const List<WordEntry> wordBank = [
  // animal
  WordEntry('lion', 'animal'), WordEntry('tiger', 'animal'), WordEntry('elephant', 'animal'),
  WordEntry('giraffe', 'animal'), WordEntry('zebra', 'animal'), WordEntry('wolf', 'animal'),
  WordEntry('bear', 'animal'), WordEntry('fox', 'animal'), WordEntry('rabbit', 'animal'),
  WordEntry('deer', 'animal'), WordEntry('horse', 'animal'), WordEntry('cow', 'animal'),
  WordEntry('sheep', 'animal'), WordEntry('goat', 'animal'), WordEntry('pig', 'animal'),
  WordEntry('dog', 'animal'), WordEntry('cat', 'animal'), WordEntry('mouse', 'animal'),
  WordEntry('squirrel', 'animal'), WordEntry('kangaroo', 'animal'), WordEntry('monkey', 'animal'),
  WordEntry('gorilla', 'animal'), WordEntry('panda', 'animal'), WordEntry('camel', 'animal'),
  WordEntry('rhinoceros', 'animal'), WordEntry('hippopotamus', 'animal'), WordEntry('raccoon', 'animal'),
  WordEntry('hedgehog', 'animal'), WordEntry('bat', 'animal'), WordEntry('leopard', 'animal'),

  // bird
  WordEntry('eagle', 'bird'), WordEntry('sparrow', 'bird'), WordEntry('robin', 'bird'),
  WordEntry('owl', 'bird'), WordEntry('hawk', 'bird'), WordEntry('falcon', 'bird'),
  WordEntry('penguin', 'bird'), WordEntry('parrot', 'bird'), WordEntry('swan', 'bird'),
  WordEntry('duck', 'bird'), WordEntry('goose', 'bird'), WordEntry('crow', 'bird'),
  WordEntry('raven', 'bird'), WordEntry('pigeon', 'bird'), WordEntry('flamingo', 'bird'),
  WordEntry('peacock', 'bird'), WordEntry('woodpecker', 'bird'), WordEntry('hummingbird', 'bird'),
  WordEntry('ostrich', 'bird'), WordEntry('seagull', 'bird'), WordEntry('stork', 'bird'),
  WordEntry('heron', 'bird'), WordEntry('kingfisher', 'bird'), WordEntry('cardinal', 'bird'),
  WordEntry('vulture', 'bird'),

  // fish
  WordEntry('salmon', 'fish'), WordEntry('trout', 'fish'), WordEntry('tuna', 'fish'),
  WordEntry('shark', 'fish'), WordEntry('cod', 'fish'), WordEntry('herring', 'fish'),
  WordEntry('catfish', 'fish'), WordEntry('goldfish', 'fish'), WordEntry('eel', 'fish'),
  WordEntry('swordfish', 'fish'), WordEntry('anchovy', 'fish'), WordEntry('mackerel', 'fish'),
  WordEntry('sardine', 'fish'), WordEntry('carp', 'fish'), WordEntry('perch', 'fish'),
  WordEntry('pike', 'fish'), WordEntry('halibut', 'fish'), WordEntry('tilapia', 'fish'),
  WordEntry('flounder', 'fish'), WordEntry('stingray', 'fish'),

  // sea_creature
  WordEntry('whale', 'sea_creature'), WordEntry('dolphin', 'sea_creature'), WordEntry('octopus', 'sea_creature'),
  WordEntry('squid', 'sea_creature'), WordEntry('jellyfish', 'sea_creature'), WordEntry('starfish', 'sea_creature'),
  WordEntry('crab', 'sea_creature'), WordEntry('lobster', 'sea_creature'), WordEntry('shrimp', 'sea_creature'),
  WordEntry('seahorse', 'sea_creature'), WordEntry('coral', 'sea_creature'), WordEntry('anemone', 'sea_creature'),
  WordEntry('walrus', 'sea_creature'), WordEntry('seal', 'sea_creature'), WordEntry('otter', 'sea_creature'),
  WordEntry('clam', 'sea_creature'), WordEntry('oyster', 'sea_creature'), WordEntry('urchin', 'sea_creature'),
  WordEntry('barnacle', 'sea_creature'), WordEntry('manatee', 'sea_creature'),

  // insect
  WordEntry('ant', 'insect'), WordEntry('bee', 'insect'), WordEntry('wasp', 'insect'),
  WordEntry('beetle', 'insect'), WordEntry('butterfly', 'insect'), WordEntry('moth', 'insect'),
  WordEntry('grasshopper', 'insect'), WordEntry('cricket', 'insect'), WordEntry('dragonfly', 'insect'),
  WordEntry('ladybug', 'insect'), WordEntry('mosquito', 'insect'), WordEntry('fly', 'insect'),
  WordEntry('termite', 'insect'), WordEntry('cockroach', 'insect'), WordEntry('cicada', 'insect'),
  WordEntry('firefly', 'insect'), WordEntry('caterpillar', 'insect'), WordEntry('aphid', 'insect'),
  WordEntry('locust', 'insect'), WordEntry('mantis', 'insect'),

  // tool
  WordEntry('hammer', 'tool'), WordEntry('screwdriver', 'tool'), WordEntry('wrench', 'tool'),
  WordEntry('pliers', 'tool'), WordEntry('saw', 'tool'), WordEntry('drill', 'tool'),
  WordEntry('chisel', 'tool'), WordEntry('file', 'tool'), WordEntry('level', 'tool'),
  WordEntry('clamp', 'tool'), WordEntry('crowbar', 'tool'), WordEntry('sander', 'tool'),
  WordEntry('ruler', 'tool'), WordEntry('trowel', 'tool'), WordEntry('scissors', 'tool'),
  WordEntry('shovel', 'tool'), WordEntry('rake', 'tool'), WordEntry('mallet', 'tool'),
  WordEntry('vise', 'tool'), WordEntry('needle', 'tool'),

  // profession
  WordEntry('doctor', 'profession'), WordEntry('teacher', 'profession'), WordEntry('engineer', 'profession'),
  WordEntry('lawyer', 'profession'), WordEntry('chef', 'profession'), WordEntry('pilot', 'profession'),
  WordEntry('nurse', 'profession'), WordEntry('electrician', 'profession'), WordEntry('plumber', 'profession'),
  WordEntry('carpenter', 'profession'), WordEntry('accountant', 'profession'), WordEntry('architect', 'profession'),
  WordEntry('farmer', 'profession'), WordEntry('dentist', 'profession'), WordEntry('scientist', 'profession'),
  WordEntry('journalist', 'profession'), WordEntry('mechanic', 'profession'), WordEntry('librarian', 'profession'),
  WordEntry('firefighter', 'profession'), WordEntry('surgeon', 'profession'), WordEntry('veterinarian', 'profession'),
  WordEntry('tailor', 'profession'), WordEntry('baker', 'profession'), WordEntry('pharmacist', 'profession'),

  // weather
  WordEntry('rain', 'weather'), WordEntry('snow', 'weather'), WordEntry('hail', 'weather'),
  WordEntry('sleet', 'weather'), WordEntry('fog', 'weather'), WordEntry('mist', 'weather'),
  WordEntry('thunder', 'weather'), WordEntry('lightning', 'weather'), WordEntry('wind', 'weather'),
  WordEntry('storm', 'weather'), WordEntry('hurricane', 'weather'), WordEntry('tornado', 'weather'),
  WordEntry('drought', 'weather'), WordEntry('flood', 'weather'), WordEntry('frost', 'weather'),
  WordEntry('dew', 'weather'), WordEntry('humidity', 'weather'), WordEntry('sunshine', 'weather'),
  WordEntry('cloud', 'weather'), WordEntry('rainbow', 'weather'), WordEntry('blizzard', 'weather'),
  WordEntry('monsoon', 'weather'), WordEntry('drizzle', 'weather'), WordEntry('heatwave', 'weather'),
  WordEntry('ice', 'weather'), WordEntry('fire', 'weather'), WordEntry('smoke', 'weather'),

  // emotion
  WordEntry('happy', 'emotion'), WordEntry('sad', 'emotion'), WordEntry('angry', 'emotion'),
  WordEntry('afraid', 'emotion'), WordEntry('surprised', 'emotion'), WordEntry('disgusted', 'emotion'),
  WordEntry('excited', 'emotion'), WordEntry('anxious', 'emotion'), WordEntry('calm', 'emotion'),
  WordEntry('jealous', 'emotion'), WordEntry('proud', 'emotion'), WordEntry('ashamed', 'emotion'),
  WordEntry('lonely', 'emotion'), WordEntry('hopeful', 'emotion'), WordEntry('grateful', 'emotion'),
  WordEntry('confused', 'emotion'), WordEntry('bored', 'emotion'), WordEntry('curious', 'emotion'),
  WordEntry('content', 'emotion'), WordEntry('frustrated', 'emotion'), WordEntry('nervous', 'emotion'),
  WordEntry('relieved', 'emotion'), WordEntry('joyful', 'emotion'), WordEntry('gloomy', 'emotion'),
  WordEntry('unhappy', 'emotion'), WordEntry('furious', 'emotion'), WordEntry('scared', 'emotion'),

  // vehicle
  WordEntry('car', 'vehicle'), WordEntry('truck', 'vehicle'), WordEntry('bus', 'vehicle'),
  WordEntry('motorcycle', 'vehicle'), WordEntry('bicycle', 'vehicle'), WordEntry('train', 'vehicle'),
  WordEntry('airplane', 'vehicle'), WordEntry('helicopter', 'vehicle'), WordEntry('boat', 'vehicle'),
  WordEntry('ship', 'vehicle'), WordEntry('submarine', 'vehicle'), WordEntry('scooter', 'vehicle'),
  WordEntry('van', 'vehicle'), WordEntry('tractor', 'vehicle'), WordEntry('ambulance', 'vehicle'),
  WordEntry('taxi', 'vehicle'), WordEntry('tram', 'vehicle'), WordEntry('glider', 'vehicle'),
  WordEntry('yacht', 'vehicle'), WordEntry('canoe', 'vehicle'), WordEntry('sled', 'vehicle'),
  WordEntry('forklift', 'vehicle'),

  // body_part
  WordEntry('head', 'body_part'), WordEntry('arm', 'body_part'), WordEntry('leg', 'body_part'),
  WordEntry('hand', 'body_part'), WordEntry('foot', 'body_part'), WordEntry('finger', 'body_part'),
  WordEntry('toe', 'body_part'), WordEntry('knee', 'body_part'), WordEntry('elbow', 'body_part'),
  WordEntry('shoulder', 'body_part'), WordEntry('chest', 'body_part'), WordEntry('back', 'body_part'),
  WordEntry('neck', 'body_part'), WordEntry('ear', 'body_part'), WordEntry('eye', 'body_part'),
  WordEntry('nose', 'body_part'), WordEntry('mouth', 'body_part'), WordEntry('chin', 'body_part'),
  WordEntry('wrist', 'body_part'), WordEntry('ankle', 'body_part'), WordEntry('hip', 'body_part'),
  WordEntry('spine', 'body_part'), WordEntry('lung', 'body_part'), WordEntry('heart', 'body_part'),
  WordEntry('liver', 'body_part'), WordEntry('kidney', 'body_part'), WordEntry('stomach', 'body_part'),
  WordEntry('skull', 'body_part'),

  // furniture
  WordEntry('chair', 'furniture'), WordEntry('table', 'furniture'), WordEntry('sofa', 'furniture'),
  WordEntry('bed', 'furniture'), WordEntry('desk', 'furniture'), WordEntry('bookshelf', 'furniture'),
  WordEntry('wardrobe', 'furniture'), WordEntry('cabinet', 'furniture'), WordEntry('drawer', 'furniture'),
  WordEntry('stool', 'furniture'), WordEntry('bench', 'furniture'), WordEntry('ottoman', 'furniture'),
  WordEntry('dresser', 'furniture'), WordEntry('nightstand', 'furniture'), WordEntry('recliner', 'furniture'),
  WordEntry('couch', 'furniture'), WordEntry('armchair', 'furniture'), WordEntry('cupboard', 'furniture'),
  WordEntry('sideboard', 'furniture'), WordEntry('rocking chair', 'furniture'),

  // instrument
  WordEntry('guitar', 'instrument'), WordEntry('piano', 'instrument'), WordEntry('violin', 'instrument'),
  WordEntry('drum', 'instrument'), WordEntry('trumpet', 'instrument'), WordEntry('flute', 'instrument'),
  WordEntry('clarinet', 'instrument'), WordEntry('saxophone', 'instrument'), WordEntry('cello', 'instrument'),
  WordEntry('harp', 'instrument'), WordEntry('trombone', 'instrument'), WordEntry('tuba', 'instrument'),
  WordEntry('banjo', 'instrument'), WordEntry('accordion', 'instrument'), WordEntry('xylophone', 'instrument'),
  WordEntry('harmonica', 'instrument'), WordEntry('bagpipes', 'instrument'), WordEntry('ukulele', 'instrument'),
  WordEntry('oboe', 'instrument'), WordEntry('bassoon', 'instrument'),

  // food
  WordEntry('bread', 'food'), WordEntry('cheese', 'food'), WordEntry('apple', 'food'),
  WordEntry('banana', 'food'), WordEntry('rice', 'food'), WordEntry('pasta', 'food'),
  WordEntry('soup', 'food'), WordEntry('salad', 'food'), WordEntry('steak', 'food'),
  WordEntry('chicken', 'food'), WordEntry('pizza', 'food'), WordEntry('sandwich', 'food'),
  WordEntry('cake', 'food'), WordEntry('cookie', 'food'), WordEntry('chocolate', 'food'),
  WordEntry('honey', 'food'), WordEntry('butter', 'food'), WordEntry('yogurt', 'food'),
  WordEntry('sausage', 'food'), WordEntry('pancake', 'food'),

  // building
  WordEntry('house', 'building'), WordEntry('castle', 'building'), WordEntry('church', 'building'),
  WordEntry('temple', 'building'), WordEntry('palace', 'building'), WordEntry('cottage', 'building'),
  WordEntry('skyscraper', 'building'), WordEntry('warehouse', 'building'), WordEntry('barn', 'building'),
  WordEntry('cabin', 'building'), WordEntry('mansion', 'building'), WordEntry('hut', 'building'),
  WordEntry('lighthouse', 'building'), WordEntry('mosque', 'building'), WordEntry('cathedral', 'building'),
  WordEntry('bungalow', 'building'), WordEntry('hangar', 'building'), WordEntry('silo', 'building'),
  WordEntry('greenhouse', 'building'), WordEntry('stadium', 'building'),

  // fabric
  WordEntry('cotton', 'fabric'), WordEntry('silk', 'fabric'), WordEntry('wool', 'fabric'),
  WordEntry('linen', 'fabric'), WordEntry('denim', 'fabric'), WordEntry('velvet', 'fabric'),
  WordEntry('leather', 'fabric'), WordEntry('polyester', 'fabric'), WordEntry('nylon', 'fabric'),
  WordEntry('satin', 'fabric'), WordEntry('tweed', 'fabric'), WordEntry('corduroy', 'fabric'),
  WordEntry('chiffon', 'fabric'), WordEntry('flannel', 'fabric'), WordEntry('suede', 'fabric'),
  WordEntry('canvas', 'fabric'), WordEntry('cashmere', 'fabric'), WordEntry('spandex', 'fabric'),
  WordEntry('lace', 'fabric'), WordEntry('felt', 'fabric'),

  // natural_feature
  WordEntry('mountain', 'natural_feature'), WordEntry('river', 'natural_feature'), WordEntry('valley', 'natural_feature'),
  WordEntry('canyon', 'natural_feature'), WordEntry('desert', 'natural_feature'), WordEntry('forest', 'natural_feature'),
  WordEntry('lake', 'natural_feature'), WordEntry('ocean', 'natural_feature'), WordEntry('waterfall', 'natural_feature'),
  WordEntry('glacier', 'natural_feature'), WordEntry('volcano', 'natural_feature'), WordEntry('cave', 'natural_feature'),
  WordEntry('cliff', 'natural_feature'), WordEntry('island', 'natural_feature'), WordEntry('peninsula', 'natural_feature'),
  WordEntry('plateau', 'natural_feature'), WordEntry('swamp', 'natural_feature'), WordEntry('reef', 'natural_feature'),
  WordEntry('delta', 'natural_feature'), WordEntry('dune', 'natural_feature'), WordEntry('fjord', 'natural_feature'),
  WordEntry('geyser', 'natural_feature'), WordEntry('lava', 'natural_feature'),

  // color
  WordEntry('red', 'color'), WordEntry('blue', 'color'), WordEntry('green', 'color'),
  WordEntry('yellow', 'color'), WordEntry('purple', 'color'), WordEntry('orange', 'color'),
  WordEntry('pink', 'color'), WordEntry('black', 'color'), WordEntry('white', 'color'),
  WordEntry('brown', 'color'), WordEntry('gray', 'color'), WordEntry('maroon', 'color'),
  WordEntry('beige', 'color'), WordEntry('indigo', 'color'), WordEntry('violet', 'color'),
  WordEntry('crimson', 'color'), WordEntry('amber', 'color'), WordEntry('teal', 'color'),
  WordEntry('lavender', 'color'), WordEntry('turquoise', 'color'),

  // sport
  WordEntry('soccer', 'sport'), WordEntry('basketball', 'sport'), WordEntry('tennis', 'sport'),
  WordEntry('baseball', 'sport'), WordEntry('hockey', 'sport'), WordEntry('golf', 'sport'),
  WordEntry('boxing', 'sport'), WordEntry('swimming', 'sport'), WordEntry('cycling', 'sport'),
  WordEntry('running', 'sport'), WordEntry('volleyball', 'sport'), WordEntry('cricket', 'sport'),
  WordEntry('rugby', 'sport'), WordEntry('badminton', 'sport'), WordEntry('wrestling', 'sport'),
  WordEntry('archery', 'sport'), WordEntry('skiing', 'sport'), WordEntry('surfing', 'sport'),
  WordEntry('rowing', 'sport'), WordEntry('fencing', 'sport'),

  // plant
  WordEntry('rose', 'plant'), WordEntry('tulip', 'plant'), WordEntry('daisy', 'plant'),
  WordEntry('sunflower', 'plant'), WordEntry('oak', 'plant'), WordEntry('pine', 'plant'),
  WordEntry('maple', 'plant'), WordEntry('willow', 'plant'), WordEntry('cactus', 'plant'),
  WordEntry('fern', 'plant'), WordEntry('bamboo', 'plant'), WordEntry('ivy', 'plant'),
  WordEntry('lily', 'plant'), WordEntry('orchid', 'plant'), WordEntry('dandelion', 'plant'),
  WordEntry('clover', 'plant'), WordEntry('moss', 'plant'), WordEntry('birch', 'plant'),
  WordEntry('cedar', 'plant'), WordEntry('palm', 'plant'), WordEntry('tree', 'plant'),

  // kitchenware
  WordEntry('pot', 'kitchenware'), WordEntry('pan', 'kitchenware'), WordEntry('spatula', 'kitchenware'),
  WordEntry('whisk', 'kitchenware'), WordEntry('ladle', 'kitchenware'), WordEntry('grater', 'kitchenware'),
  WordEntry('colander', 'kitchenware'), WordEntry('blender', 'kitchenware'), WordEntry('toaster', 'kitchenware'),
  WordEntry('kettle', 'kitchenware'), WordEntry('cutting board', 'kitchenware'), WordEntry('rolling pin', 'kitchenware'),
  WordEntry('peeler', 'kitchenware'), WordEntry('tongs', 'kitchenware'), WordEntry('sieve', 'kitchenware'),
  WordEntry('skillet', 'kitchenware'), WordEntry('saucepan', 'kitchenware'), WordEntry('oven mitt', 'kitchenware'),
  WordEntry('measuring cup', 'kitchenware'), WordEntry('corkscrew', 'kitchenware'), WordEntry('knife', 'kitchenware'),

  // clothing
  WordEntry('shirt', 'clothing'), WordEntry('trousers', 'clothing'), WordEntry('dress', 'clothing'),
  WordEntry('jacket', 'clothing'), WordEntry('sweater', 'clothing'), WordEntry('coat', 'clothing'),
  WordEntry('skirt', 'clothing'), WordEntry('shorts', 'clothing'), WordEntry('blouse', 'clothing'),
  WordEntry('scarf', 'clothing'), WordEntry('glove', 'clothing'), WordEntry('hat', 'clothing'),
  WordEntry('sock', 'clothing'), WordEntry('shoe', 'clothing'), WordEntry('boot', 'clothing'),
  WordEntry('belt', 'clothing'), WordEntry('tie', 'clothing'), WordEntry('vest', 'clothing'),
  WordEntry('pajamas', 'clothing'), WordEntry('poncho', 'clothing'),

  // celestial
  WordEntry('sun', 'celestial'), WordEntry('moon', 'celestial'), WordEntry('star', 'celestial'),
  WordEntry('planet', 'celestial'), WordEntry('comet', 'celestial'), WordEntry('asteroid', 'celestial'),
  WordEntry('galaxy', 'celestial'), WordEntry('nebula', 'celestial'), WordEntry('meteor', 'celestial'),
  WordEntry('satellite', 'celestial'), WordEntry('constellation', 'celestial'), WordEntry('eclipse', 'celestial'),
  WordEntry('mars', 'celestial'), WordEntry('jupiter', 'celestial'), WordEntry('saturn', 'celestial'),
  WordEntry('venus', 'celestial'), WordEntry('mercury', 'celestial'), WordEntry('neptune', 'celestial'),
  WordEntry('uranus', 'celestial'), WordEntry('pluto', 'celestial'),

  // gemstone
  WordEntry('diamond', 'gemstone'), WordEntry('ruby', 'gemstone'), WordEntry('emerald', 'gemstone'),
  WordEntry('sapphire', 'gemstone'), WordEntry('topaz', 'gemstone'), WordEntry('opal', 'gemstone'),
  WordEntry('amethyst', 'gemstone'), WordEntry('garnet', 'gemstone'), WordEntry('pearl', 'gemstone'),
  WordEntry('jade', 'gemstone'), WordEntry('onyx', 'gemstone'), WordEntry('aquamarine', 'gemstone'),
  WordEntry('citrine', 'gemstone'), WordEntry('peridot', 'gemstone'), WordEntry('moonstone', 'gemstone'),
  WordEntry('tourmaline', 'gemstone'), WordEntry('agate', 'gemstone'), WordEntry('quartz', 'gemstone'),
  WordEntry('zircon', 'gemstone'), WordEntry('malachite', 'gemstone'),

  // weapon
  WordEntry('sword', 'weapon'), WordEntry('spear', 'weapon'), WordEntry('arrow', 'weapon'),
  WordEntry('bow', 'weapon'), WordEntry('shield', 'weapon'), WordEntry('dagger', 'weapon'),
  WordEntry('mace', 'weapon'), WordEntry('lance', 'weapon'), WordEntry('crossbow', 'weapon'),
  WordEntry('javelin', 'weapon'), WordEntry('catapult', 'weapon'), WordEntry('musket', 'weapon'),
  WordEntry('cannon', 'weapon'), WordEntry('rifle', 'weapon'), WordEntry('pistol', 'weapon'),
  WordEntry('sling', 'weapon'), WordEntry('halberd', 'weapon'), WordEntry('rapier', 'weapon'),
  WordEntry('trident', 'weapon'), WordEntry('whip', 'weapon'), WordEntry('axe', 'weapon'),

  // trait (descriptive adjectives — used for synonym/antonym pairs)
  WordEntry('big', 'trait'), WordEntry('small', 'trait'), WordEntry('hot', 'trait'),
  WordEntry('cold', 'trait'), WordEntry('fast', 'trait'), WordEntry('slow', 'trait'),
  WordEntry('strong', 'trait'), WordEntry('weak', 'trait'), WordEntry('bright', 'trait'),
  WordEntry('dark', 'trait'), WordEntry('heavy', 'trait'), WordEntry('light', 'trait'),
  WordEntry('loud', 'trait'), WordEntry('quiet', 'trait'), WordEntry('clean', 'trait'),
  WordEntry('dirty', 'trait'), WordEntry('easy', 'trait'), WordEntry('difficult', 'trait'),
  WordEntry('rich', 'trait'), WordEntry('poor', 'trait'), WordEntry('young', 'trait'),
  WordEntry('old', 'trait'), WordEntry('wide', 'trait'), WordEntry('narrow', 'trait'),
  WordEntry('thick', 'trait'), WordEntry('thin', 'trait'), WordEntry('tall', 'trait'),
  WordEntry('short', 'trait'), WordEntry('brave', 'trait'), WordEntry('cowardly', 'trait'),
  WordEntry('generous', 'trait'), WordEntry('selfish', 'trait'), WordEntry('honest', 'trait'),
  WordEntry('dishonest', 'trait'), WordEntry('kind', 'trait'), WordEntry('cruel', 'trait'),
  WordEntry('wise', 'trait'), WordEntry('foolish', 'trait'), WordEntry('large', 'trait'),
  WordEntry('tiny', 'trait'), WordEntry('quick', 'trait'), WordEntry('powerful', 'trait'),
  WordEntry('intelligent', 'trait'), WordEntry('humorous', 'trait'), WordEntry('beautiful', 'trait'),
  WordEntry('exhausted', 'trait'), WordEntry('wealthy', 'trait'), WordEntry('courageous', 'trait'),
  WordEntry('silent', 'trait'), WordEntry('noisy', 'trait'), WordEntry('simple', 'trait'),
  WordEntry('ancient', 'trait'), WordEntry('modern', 'trait'), WordEntry('full', 'trait'),
  WordEntry('empty', 'trait'), WordEntry('open', 'trait'), WordEntry('closed', 'trait'),
  WordEntry('funny', 'trait'), WordEntry('hard', 'trait'),

  // part (components and materials — used for part-of / function pairs)
  WordEntry('wheel', 'part'), WordEntry('engine', 'part'), WordEntry('branch', 'part'),
  WordEntry('leaf', 'part'), WordEntry('root', 'part'), WordEntry('trunk', 'part'),
  WordEntry('petal', 'part'), WordEntry('page', 'part'), WordEntry('roof', 'part'),
  WordEntry('door', 'part'), WordEntry('window', 'part'), WordEntry('handle', 'part'),
  WordEntry('blade', 'part'), WordEntry('string', 'part'), WordEntry('wing', 'part'),
  WordEntry('tail', 'part'), WordEntry('fin', 'part'), WordEntry('claw', 'part'),
  WordEntry('key', 'part'), WordEntry('lock', 'part'), WordEntry('sole', 'part'),
  WordEntry('sleeve', 'part'), WordEntry('collar', 'part'), WordEntry('cover', 'part'),
  WordEntry('wood', 'part'), WordEntry('paper', 'part'), WordEntry('thread', 'part'),
  WordEntry('pipe', 'part'),

  // role (people or things on the receiving end of an action)
  WordEntry('patient', 'role'), WordEntry('student', 'role'), WordEntry('customer', 'role'),
  WordEntry('passenger', 'role'), WordEntry('audience', 'role'), WordEntry('guest', 'role'),
  WordEntry('client', 'role'), WordEntry('employee', 'role'), WordEntry('visitor', 'role'),
  WordEntry('opponent', 'role'),

  // reading_material
  WordEntry('book', 'reading_material'), WordEntry('magazine', 'reading_material'), WordEntry('newspaper', 'reading_material'),
  WordEntry('novel', 'reading_material'), WordEntry('diary', 'reading_material'), WordEntry('journal', 'reading_material'),
  WordEntry('comic', 'reading_material'),
];

const List<WordPair> wordPairs = [
  // synonym
  WordPair('big', 'large', WordRelation.synonym),
  WordPair('small', 'tiny', WordRelation.synonym),
  WordPair('fast', 'quick', WordRelation.synonym),
  WordPair('happy', 'joyful', WordRelation.synonym),
  WordPair('sad', 'unhappy', WordRelation.synonym),
  WordPair('angry', 'furious', WordRelation.synonym),
  WordPair('afraid', 'scared', WordRelation.synonym),
  WordPair('strong', 'powerful', WordRelation.synonym),
  WordPair('wise', 'intelligent', WordRelation.synonym),
  WordPair('difficult', 'hard', WordRelation.synonym),
  WordPair('rich', 'wealthy', WordRelation.synonym),
  WordPair('brave', 'courageous', WordRelation.synonym),
  WordPair('quiet', 'silent', WordRelation.synonym),
  WordPair('loud', 'noisy', WordRelation.synonym),
  WordPair('easy', 'simple', WordRelation.synonym),
  WordPair('old', 'ancient', WordRelation.synonym),
  WordPair('sad', 'gloomy', WordRelation.synonym),
  WordPair('kind', 'generous', WordRelation.synonym),
  WordPair('funny', 'humorous', WordRelation.synonym),

  // antonym
  WordPair('big', 'small', WordRelation.antonym),
  WordPair('hot', 'cold', WordRelation.antonym),
  WordPair('fast', 'slow', WordRelation.antonym),
  WordPair('strong', 'weak', WordRelation.antonym),
  WordPair('bright', 'dark', WordRelation.antonym),
  WordPair('heavy', 'light', WordRelation.antonym),
  WordPair('loud', 'quiet', WordRelation.antonym),
  WordPair('clean', 'dirty', WordRelation.antonym),
  WordPair('easy', 'difficult', WordRelation.antonym),
  WordPair('rich', 'poor', WordRelation.antonym),
  WordPair('young', 'old', WordRelation.antonym),
  WordPair('wide', 'narrow', WordRelation.antonym),
  WordPair('thick', 'thin', WordRelation.antonym),
  WordPair('tall', 'short', WordRelation.antonym),
  WordPair('brave', 'cowardly', WordRelation.antonym),
  WordPair('generous', 'selfish', WordRelation.antonym),
  WordPair('honest', 'dishonest', WordRelation.antonym),
  WordPair('kind', 'cruel', WordRelation.antonym),
  WordPair('wise', 'foolish', WordRelation.antonym),
  WordPair('happy', 'sad', WordRelation.antonym),
  WordPair('full', 'empty', WordRelation.antonym),
  WordPair('open', 'closed', WordRelation.antonym),
  WordPair('ancient', 'modern', WordRelation.antonym),

  // partOf
  WordPair('wheel', 'car', WordRelation.partOf),
  WordPair('engine', 'car', WordRelation.partOf),
  WordPair('branch', 'tree', WordRelation.partOf),
  WordPair('leaf', 'tree', WordRelation.partOf),
  WordPair('root', 'tree', WordRelation.partOf),
  WordPair('trunk', 'tree', WordRelation.partOf),
  WordPair('petal', 'rose', WordRelation.partOf),
  WordPair('roof', 'house', WordRelation.partOf),
  WordPair('door', 'house', WordRelation.partOf),
  WordPair('window', 'house', WordRelation.partOf),
  WordPair('blade', 'knife', WordRelation.partOf),
  WordPair('handle', 'hammer', WordRelation.partOf),
  WordPair('string', 'guitar', WordRelation.partOf),
  WordPair('wing', 'airplane', WordRelation.partOf),
  WordPair('tail', 'dog', WordRelation.partOf),
  WordPair('fin', 'shark', WordRelation.partOf),
  WordPair('claw', 'lobster', WordRelation.partOf),
  WordPair('key', 'piano', WordRelation.partOf),
  WordPair('sole', 'shoe', WordRelation.partOf),
  WordPair('sleeve', 'shirt', WordRelation.partOf),
  WordPair('collar', 'shirt', WordRelation.partOf),
  WordPair('page', 'diary', WordRelation.partOf),

  // function (item used to do X)
  WordPair('scissors', 'cotton', WordRelation.function),
  WordPair('drill', 'wood', WordRelation.function),
  WordPair('needle', 'thread', WordRelation.function),
  WordPair('rake', 'leaf', WordRelation.function),
  WordPair('key', 'lock', WordRelation.function),
  WordPair('toaster', 'bread', WordRelation.function),
  WordPair('grater', 'cheese', WordRelation.function),
  WordPair('peeler', 'apple', WordRelation.function),
  WordPair('teacher', 'student', WordRelation.function),
  WordPair('chef', 'bread', WordRelation.function),
  WordPair('pilot', 'airplane', WordRelation.function),
  WordPair('surgeon', 'patient', WordRelation.function),
  WordPair('carpenter', 'wood', WordRelation.function),
  WordPair('tailor', 'shirt', WordRelation.function),
  WordPair('plumber', 'pipe', WordRelation.function),
  WordPair('bow', 'arrow', WordRelation.function),
  WordPair('trowel', 'rose', WordRelation.function),
  WordPair('crossbow', 'arrow', WordRelation.function),
  WordPair('nurse', 'patient', WordRelation.function),

  // causeEffect
  WordPair('rain', 'flood', WordRelation.causeEffect),
  WordPair('storm', 'flood', WordRelation.causeEffect),
  WordPair('hurricane', 'flood', WordRelation.causeEffect),
  WordPair('volcano', 'lava', WordRelation.causeEffect),
  WordPair('frost', 'ice', WordRelation.causeEffect),
  WordPair('lightning', 'thunder', WordRelation.causeEffect),
  WordPair('blizzard', 'snow', WordRelation.causeEffect),
  WordPair('heatwave', 'drought', WordRelation.causeEffect),
  WordPair('fire', 'smoke', WordRelation.causeEffect),
];
