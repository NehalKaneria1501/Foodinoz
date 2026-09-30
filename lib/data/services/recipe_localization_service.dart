import '../models/recipe_model.dart';

class RecipeLocalizationService {
  // Translate Recipe Title
  static String getRecipeTitle(String englishTitle, RecipeLanguage lang) {
    if (lang == RecipeLanguage.english) return englishTitle;

    final match = _titles[englishTitle.trim()];
    if (match != null) {
      return lang == RecipeLanguage.gujarati ? match.gujarati : match.hindi;
    }
    return englishTitle;
  }

  // Translate Recipe Description
  static String getRecipeDescription(String englishDesc, RecipeLanguage lang) {
    if (lang == RecipeLanguage.english) return englishDesc;

    final match = _descriptions[englishDesc.trim()];
    if (match != null) {
      return lang == RecipeLanguage.gujarati ? match.gujarati : match.hindi;
    }
    return englishDesc;
  }

  // Translate Ingredient Name
  static String getIngredientName(String englishName, RecipeLanguage lang) {
    if (lang == RecipeLanguage.english) return englishName;

    for (final entry in _ingredients.entries) {
      if (englishName.toLowerCase().contains(entry.key.toLowerCase())) {
        return lang == RecipeLanguage.gujarati ? entry.value.gujarati : entry.value.hindi;
      }
    }
    return englishName;
  }

  // Localize an entire RecipeModel dynamically
  static RecipeModel localize(RecipeModel recipe, RecipeLanguage lang) {
    if (lang == RecipeLanguage.english) return recipe;

    final localizedTitle = (lang == RecipeLanguage.gujarati && recipe.titleGujarati != null)
        ? recipe.titleGujarati!
        : (lang == RecipeLanguage.hindi && recipe.titleHindi != null)
            ? recipe.titleHindi!
            : getRecipeTitle(recipe.title, lang);

    final localizedDesc = (lang == RecipeLanguage.gujarati && recipe.descriptionGujarati != null)
        ? recipe.descriptionGujarati!
        : (lang == RecipeLanguage.hindi && recipe.descriptionHindi != null)
            ? recipe.descriptionHindi!
            : getRecipeDescription(recipe.description, lang);

    final localizedIngredients = recipe.ingredients.map((ing) {
      final name = ing.getName(lang);
      final finalName = name != ing.name ? name : getIngredientName(ing.name, lang);
      return ing.copyWith(
        nameGujarati: lang == RecipeLanguage.gujarati ? finalName : ing.nameGujarati,
        nameHindi: lang == RecipeLanguage.hindi ? finalName : ing.nameHindi,
      );
    }).toList();

    final localizedSteps = recipe.steps.map((step) {
      final stepInfo = _getStepLocalization(recipe.title, step.stepNumber, step.title, step.instruction, lang);
      return step.copyWith(
        titleGujarati: lang == RecipeLanguage.gujarati ? stepInfo.title : step.titleGujarati,
        titleHindi: lang == RecipeLanguage.hindi ? stepInfo.title : step.titleHindi,
        instructionGujarati: lang == RecipeLanguage.gujarati ? stepInfo.instruction : step.instructionGujarati,
        instructionHindi: lang == RecipeLanguage.hindi ? stepInfo.instruction : step.instructionHindi,
        flameLevel: step.flameLevel ?? stepInfo.flame,
        proTip: step.proTip ?? stepInfo.proTip,
        proTipGujarati: lang == RecipeLanguage.gujarati ? stepInfo.proTip : step.proTipGujarati,
        proTipHindi: lang == RecipeLanguage.hindi ? stepInfo.proTip : step.proTipHindi,
      );
    }).toList();

    return recipe.copyWith(
      title: localizedTitle,
      description: localizedDesc,
      ingredients: localizedIngredients,
      steps: localizedSteps,
    );
  }

  // Step localization generator from scratch to advanced
  static _StepLoc _getStepLocalization(String recipeTitle, int stepNum, String engTitle, String engInst, RecipeLanguage lang) {
    final lowerTitle = engTitle.toLowerCase();
    final lowerInst = engInst.toLowerCase();

    String titleGu = engTitle;
    String titleHi = engTitle;
    String instGu = engInst;
    String instHi = engInst;
    String flame = 'Medium Flame';
    String tipGu = 'પ્રો ટિપ: શ્રેષ્ઠ સ્વાદ માટે મસાલા યોગ્ય તાપે સાંતળો.';
    String tipHi = 'प्रो टिप: सर्वोत्तम स्वाद के लिए मसाले मध्यम आंच पर भूनें।';
    String tipEn = 'Pro Tip: Maintain consistent flame control to preserve delicate aromas.';

    if (stepNum == 1 || lowerTitle.contains('prep') || lowerTitle.contains('chop') || lowerTitle.contains('knead') || lowerTitle.contains('grind')) {
      flame = 'Low Flame';
      titleGu = 'સ્ટેપ ૧ (તૈયારી): સામગ્રી માપન અને પ્રાથમિક સુધારણા';
      titleHi = 'चरण १ (तैयारी): सामग्री का नाप और शुरुआती तैयारी';
      instGu = 'તમામ સામગ્રીને તાજી લો. સ્વચ્છ પાણીથી ધોઈ, કોરી કરી બારીક સુધારો અથવા લોટ તૈયાર કરો. સામગ્રી ઓરડાના તાપમાને હોવી જરૂરી છે.';
      instHi = 'सभी ताज़ा सामग्री को साफ़ पानी से धोकर सुखाएं और बारीक काटें अथवा आटा गूंथें। सामग्री सामान्य तापमान पर होनी चाहिए।';
      tipGu = 'સ્ક્રેચ ટિપ: બટાકા કે શાકભાજી સુધારતી વખતે વધારે ભેજ ન રહે તેનું ધ્યાન રાખો.';
      tipHi = 'स्क्रैच टिप: सब्जियां काटते समय अधिक नमी न रहे, कपड़े से पोंछ लें।';
      tipEn = 'Scratch Tip: Ensure produce is patted dry after washing so it sautés without turning soggy.';
    } else if (lowerInst.contains('pouch') || lowerInst.contains('masala') || lowerTitle.contains('tadka') || lowerTitle.contains('roast')) {
      flame = 'Medium Flame';
      titleGu = 'સ્ટેપ $stepNum (મસાલા ઇન્ફ્યુઝન): જીરોલા મસાલા પાઉચ ઉમેરો';
      titleHi = 'चरण $stepNum (मसाला मिश्रण): जीरोला मसाला पाउच मिलाएं';
      instGu = 'ગરમ તેલ અથવા દેશી ઘીમાં જીરોલા મસાલા પાઉચ ખોલીને ઉમેરો. મસાલાની સુગંધ છૂટે ત્યાં સુધી ૪૫ સેકન્ડ ધીમાથી મધ્યમ તાપે સાંતળો.';
      instHi = 'गर्म तेल या देसी घी में जीरोला मसाला पाउच खोलकर डालें। मसालों की महक आने तक ४५ सेकंड धीमी-मध्यम आंच पर भूनें।';
      tipGu = 'ટેકનિક ટિપ: તેલ વધારે ગરમ ન હોવું જોઈએ જેથી મસાલાના સુગંધિત તેલ બળી ન જાય.';
      tipHi = 'तकनीक टिप: तेल अत्यधिक गर्म न हो ताकि साबुत मसालों के प्राकृतिक सुगंधित तेल न जलें।';
      tipEn = 'Technique Tip: Never add spice powder to smoking oil; low-medium heat blooms the essential oils safely.';
    } else if (lowerTitle.contains('simmer') || lowerTitle.contains('cook') || lowerTitle.contains('dum')) {
      flame = 'Simmer';
      titleGu = 'સ્ટેપ $stepNum (ધીમો ઉકાળો): ગ્રેવી અને શાક ધીમી આંચે પકવો';
      titleHi = 'चरण $stepNum (धीमी आंच): ग्रेवी और सब्जी को धीमी आंच पर पकाएं';
      instGu = 'ઢાંકણ ઢાંકીને ધીમા તાપે ૮ થી ૧૦ મિનિટ સુધી પકવો જેથી શાકભાજીમાં મસાલાનો સ્વાદ ઊંડે સુધી ઊતરી જાય અને તેલ છૂટું પડે.';
      instHi = 'ढक्कन लगाकर धीमी आंच पर ८ से १० मिनट पकाएं ताकि मसालों का स्वाद अंदर तक समा जाए और तेल ऊपर तैरने लगे।';
      tipGu = 'એડવાન્સ્ડ ટિપ: ગ્રેવીની સપાટી પર ચમકતું તેલ દેખાય એટલે સમજવું કે ગ્રેવી સંપૂર્ણ પાકી ગઈ છે.';
      tipHi = 'एडवांस्ड टिप: तरी की सतह पर चमकता हुआ तेल अलग होना सही पकने का मुख्य संकेत है।';
      tipEn = 'Advanced Tip: Look for oil or ghee gently glistening on the perimeter of the pan as the true cue of doneness.';
    } else if (lowerTitle.contains('fry') || lowerTitle.contains('crisp') || lowerTitle.contains('bake')) {
      flame = 'High Flame';
      titleGu = 'સ્ટેપ $stepNum (તળવું / શેકવું): સોનેરી અને ક્રિસ્પી બનાવો';
      titleHi = 'चरण $stepNum (तलना / सेंकना): सुनहरा और कुरकुरा बनाएं';
      instGu = 'ગરમ તેલમાં ગોલ્ડન બ્રાઉન અને એકદમ કરકરા થાય ત્યાં સુધી તળો. ઝારાથી વધારાનું તેલ નિતારી ટિશ્યુ પર કાઢો.';
      instHi = 'गरम तेल में सुनहरा और एकदम कुरकुरा होने तक तलें। जालीदार पौनी से अतिरिक्त तेल निथार कर निकालें।';
      tipGu = 'શેફ સિક્રેટ: એકસાથે વધારે માત્રામાં ન તળો જેથી તેલનું તાપમાન ન ઘટી જાય.';
      tipHi = 'शेफ सीक्रेट: एक साथ बहुत सारे टुकड़े न डालें ताकि तेल का तापमान स्थिर रहे।';
      tipEn = 'Chef Secret: Fry in small batches to maintain oil temperature and prevent greasy absorption.';
    } else {
      flame = 'Low Flame';
      titleGu = 'સ્ટેપ $stepNum (ફિનિશિંગ): ગાર્નિશ અને પીરસવું';
      titleHi = 'चरण $stepNum (अंतिम स्पर्श): सजावट और गर्मागर्म परोसना';
      instGu = 'ગેસ બંધ કરો. તાજી કોથમીર, મલાઈ અથવા ઘી ઉમેરી ૨ મિનિટ ઢાંકીને રેસ્ટ આપો, પછી ગરમાગરમ પીરસો.';
      instHi = 'गैस बंद करें। ताज़ा हरा धनिया, मलाई या घी डालकर २ मिनट ढक कर रखें, फिर गर्मागर्म परोसें।';
      tipGu = 'માસ્ટર ફિનિશ: પીરસતાં પહેલાં ૨ મિનિટ ઢાંકી રાખવાથી સ્વાદ બેવડાય છે.';
      tipHi = 'मास्टर फिनिश: परोसने से पहले २ मिनट का आराम भोजन के स्वाद को पूरी तरह विकसित करता है।';
      tipEn = 'Master Finish: Resting the cooked dish covered for 2 minutes allows the flavors to harmonize.';
    }

    if (lang == RecipeLanguage.gujarati) {
      return _StepLoc(titleGu, instGu, flame, tipGu);
    } else if (lang == RecipeLanguage.hindi) {
      return _StepLoc(titleHi, instHi, flame, tipHi);
    } else {
      return _StepLoc(engTitle, engInst, flame, tipEn);
    }
  }

  // Titles dictionary
  static final Map<String, _Trans> _titles = {
    'Farali Pizza': _Trans('ફરાળી પિઝા (રાજગરા ક્રસ્ટ)', 'फराली पिज्जा (राजगीरा क्रस्ट)'),
    'Kuttu Puri': _Trans('કુટ્ટુની પૂરી (વ્રત સ્પેશિયલ)', 'कुट्टू की पूरी (व्रत स्पेशल)'),
    'Farali Mendu Vada Shambhar': _Trans('ફરાળી મેંદુ વડા અને સાંભાર', 'फराली मेंदू वड़ा और सांभर'),
    'Farali Sabudanada Paratha': _Trans('ફરાળી સાબુદાણા પરોઠા', 'फराली साबूदाना पराठा'),
    'Farali Brokli Paratha': _Trans('ફરાળી બ્રોકોલી પરોઠા', 'फराली ब्रोकली पराठा'),
    'Farali Chevado': _Trans('ફરાળી ચેવડો (બટાકા-ડ્રાયફ્રુટ)', 'फराली चिवड़ा (आलू-मेवे)'),
    'Farali Idli Shambhar': _Trans('ફરાળી ઇડલી અને સાંભાર', 'फराली इडली और सांभर'),
    'Farali Dosa': _Trans('ફરાળી ક્રિસ્પી ઢોસા', 'फराली कुरकुरा डोसा'),
    'Farali Dahivada': _Trans('ફરાળી દહીવડા', 'फराली दहीवड़ा'),
    'Farali Bateta Vada': _Trans('ફરાળી બટેટા વડા', 'फराली आलू वड़ा'),
    'Dalvada': _Trans('કાઠિયાવાડી દાળવડા', 'काठियावाड़ी दालवड़ा'),
    'Vatidal Na Khaman': _Trans('સુરતી વાટીદાળ ના ખમણ', 'सुरती वाटी दाल खमन'),
    'Badam Shiro': _Trans('શાહી બદામ શીરો (હલવો)', 'शाही बादाम हलवा (शीरा)'),
    'Palak Paneer Dosa': _Trans('પાલક પનીર ફ્યુઝન ઢોસા', 'पालक पनीर फ्यूजन डोसा'),
    'Paneer Lababdar': _Trans('શાહી પનીર લબાબદાર', 'शाही पनीर लबाबदार'),
    'Manchurian Fried Rice': _Trans('મંચુરિયન ફ્રાઈડ રાઇસ', 'मंचूरियन फ्राइड राइस'),
    'Kaju Katri': _Trans('કાજુ કતરી (કાજુ કતલી)', 'काजू कतली'),
    'Spring Roll': _Trans('ક્રિસ્પી વેજ સ્પ્રિંગ રોલ', 'कुरकुरा वेज स्प्रिंग रोल'),
    'Mohanthal': _Trans('ગુજરાતી દેશી ઘી મોહનથાળ', 'पारंपरिक गुजराती मोहनथाल'),
    'Bhakkharvadi': _Trans('વડોદરા સ્પેશિયલ ભાખરવડી', 'भाकरवड़ी (मसालेदार रोल)'),
    'Mathiya Puri': _Trans('મઠિયા પૂરી (દિવાળી સ્પેશિયલ)', 'मठिया पूरी (त्योहारी स्पेशल)'),
    'Chocolate Cake': _Trans('ચોકલેટ ફજ સ્પોન્જ કેક', 'चॉकलेट फज स्पंज केक'),
    'Samosa Chat': _Trans('ચટપટી દિલ્હી સમોસા ચાટ', 'चटपटी समोसा चाट'),
    'Farali Khichu': _Trans('ફરાળી ખીચું (તેલ-મસાલા સાથે)', 'फराली खीचू'),
    'Cheese Corn Samosa': _Trans('ચીઝ કોર્ન સમોસા', 'चीज़ कॉर्न समोसा'),
    'Ghughara Sandwich': _Trans('રાજકોટ પ્રખ્યાત ઘૂઘરા સેન્ડવિચ', 'राजकोट प्रसिद्ध घुघरा सैंडविच'),
    'Farali Paneer Masala': _Trans('ફરાળી શાહી પનીર મસાલા', 'फराली शाही पनीर मसाला'),
    'Katori Chat': _Trans('ક્રિસ્પી કટોરી ચાટ', 'कुरकुरी कटोरी चाट'),
    'Farali Mohanthal': _Trans('ફરાળી મોહનથાળ (શીંગોડા લોટ)', 'फराली मोहनथाल (सिंघाड़ा आटा)'),
    'Gundar Pak': _Trans('શિયાળુ ગુંદર પાક', 'सर्दियों का गोंद पाक'),
    'Soya Sticks': _Trans('ચટપટા સોયા સ્ટીક્સ', 'चटपटे सोया स्टिक्स'),
    'Fadhi Pakoda': _Trans('ફઢી પકોડા (મરી-અજમો)', 'फढ़ी पकोड़ा (काली मिर्च)'),
    'Tal Chikki': _Trans('તલની ચીકી (મકરસંક્રાંતિ)', 'तिल की चिक्की'),
    'Dahi Bhindi': _Trans('દહીં ભીંડાનું શાક', 'दही भिंडी मसाला'),
    'Chili Potato': _Trans('હની ચિલી પોટેટો', 'हनी चिली पोटैटो'),
    'Tomato Sev': _Trans('કાઠિયાવાડી સેવ ટામેટાંનું શાક', 'काठियावाड़ी सेव टमाटर सब्जी'),
    'Badam Puri': _Trans('પારંપરિક બદામ પૂરી', 'पारंपरिक बादाम पूरी'),
    'Ragada Samosa': _Trans('રગડા સમોસા ચાટ', 'रगड़ा समोसा चाट'),
    'Vatana Puri': _Trans('લીલા વટાણાની પૂરી', 'हरे मटर की पूरी'),
    'Tal Na Ladu': _Trans('તલના લાડુ (ગોળ-તલ)', 'तिल के लड्डू (गुड़-तिल)'),
    'Bundi Raitu': _Trans('ઠંડુ બુંદી રાયતું', 'ठंडा बूंदी रायता'),
    'Farali Paratha': _Trans('ફરાળી રાજગરા પરોઠા', 'फराली राजगीरा पराठा'),
    'Pauva Chevdo': _Trans('શેકેલા પૌંઆનો ચેવડો', 'भुने पोहे का चिवड़ा'),
    'No Bread Sandwich': _Trans('નો-બ્રેડ હેલ્ધી પનીર સેન્ડવિચ', 'नो-ब्रेड पनीर सैंडविच'),
    'Mexican Burgur': _Trans('મેક્સીકન બીન બર્ગર', 'मेक्सिकन बीन बर्गर'),
    'Mango Firni': _Trans('શાહી કેરીની ફિરની (મેંગો ફિરની)', 'शाही मैंगो फिरनी'),
    'Cheese Bread': _Trans('ગાર્લિક ચીઝ પુલ-અપાર્ટ બ્રેડ', 'गार्लिक चीज़ ब्रेड'),
    'Mango Doli Icecream': _Trans('મેંગો ડોલી આઇસક્રીમ બાર', 'मैंगो डॉली आइसक्रीम बार'),
    'Sev Usal': _Trans('વડોદરા સ્પેશિયલ તારી સેવ ઉસળ', 'वडोदरा स्पेशल तारी सेव उसल'),
    'Suka Nariyalni Cake': _Trans('સૂકા નાળિયેરની કેક', 'सूखे नारियल का केक'),
    'Pencake': _Trans('અમેરિકન ફ્લફી પેનકેક', 'फ्लफी पैनकेक'),
    'Homemade Artisan Cheese': _Trans('ઘરે બનાવેલું હર્બ ચીઝ / પનીર', 'घर का बना ताज़ा हर्ब चीज़'),
    'Chimichangas': _Trans('મેક્સીકન ક્રિસ્પી ચીમીચાંગાસ', 'मेक्सिकन चिमीचांगा'),
    'Mexican Dosa': _Trans('મેક્સીકન સાલસા ઢોસા', 'मेक्सिकन सालसा डोसा'),
    'Kenya Style Maruna Bhajiya': _Trans('કેન્યા નાયરોબી સ્ટાઈલ મારુ ભજીયા', 'मारू भजिया (केन्या स्टाइल)'),
    'Steamed Vegetable Momos': _Trans('સ્ટીમ્ડ વેજ મોમોઝ', 'स्टीम्ड वेज मोमोज'),
    'Vanilla Cake': _Trans('બેકરી સ્ટાઇલ વેનીલા કેક', 'बेकरी स्टाइल वैनिला केक'),
    'Mexican Rice': _Trans('ટોમેટો ચિપોટલે મેક્સીકન રાઇસ', 'मेक्सिकन राइस'),
    'Ekadasi Special Dosa': _Trans('એકાદશી સ્પેશિયલ વ્રત ઢોસા', 'एकादशी स्पेशल व्रत डोसा'),
    'Shravan Special Farali Cake': _Trans('શ્રાવણ સ્પેશિયલ ફરાળી કેક', 'श्रावण स्पेशल फराली केक'),
    'Farali Mongo Chilli': _Trans('ફરાળી કાચી કેરી-મરચાંનું કચૂંબર', 'कच्ची कैरी मिर्च का संभारा'),
    'Vada Pav': _Trans('મુંબઈ સ્પેશિયલ વડા પાઉં', 'मुंबई स्पेशल वड़ा पाव'),
    'Paneer Butter Masala': _Trans('પનીર બટર મસાલા', 'पनीर बटर मसाला'),
    'Mushroom Matar Masala': _Trans('મશરૂમ વટાણા મસાલા', 'मशरूम मटर मसाला'),
    'Kadai Paneer': _Trans('કડાઈ પનીર', 'कड़ाही पनीर'),
    'Classic Dal Tadka': _Trans('દેશી ઘી વાળી દાળ તડકા', 'देसी घी वाली दाल तड़का'),
    'Vegetable Dum Biryani': _Trans('શાહી વેજ દમ બિરયાની', 'शाही वेज दम बिरयानी'),
    'Jain Shahi Paneer': _Trans('જૈન શાહી પનીર', 'जैन शाही पनीर'),
  };

  // Descriptions dictionary
  static final Map<String, _Trans> _descriptions = {
    'Rich, creamy cottage cheese curry simmered in a luscious tomato-cashew gravy with Jeerola Royal Shahi blend.':
        _Trans('કાજુ અને ટામેટાંની મલાઈદાર ગ્રેવીમાં રાંધેલું નરમ પનીર અને જીરોલા રોયલ શાહી મસાલાનો સ્વાદિષ્ટ સંગમ.', 'काजू और टमाटर की मखमली ग्रेवी में पका कोमल पनीर और जीरोला रॉयल शाही मसाले का स्वादिष्ट मेल।'),
    'Crisp gluten-free fasting pizza base made with tapioca and rajgira flour, topped with homemade tomato sauce, paneer cubes, and melted mozzarella.':
        _Trans('સાબુદાણા અને રાજગરાના લોટનો કરકરો ગ્લુટેન-ફ્રી બેઝ, હોમમેડ ટોમેટો સોસ, પનીર અને ચીઝથી ભરપૂર ફરાળી પિઝા.', 'साबूदाना और राजगीरा आटे का कुरकुरा व्रत बेस, घर की बनी टमाटर सॉस, पनीर और चीज़ से भरपूर फराली पिज्जा।'),
  };

  // Ingredients dictionary
  static final Map<String, _Trans> _ingredients = {
    'paneer': _Trans('પનીર (કોટેજ ચીઝ)', 'पनीर (कॉटेज चीज़)'),
    'tomato': _Trans('તાજા લાલ ટામેટાં', 'ताज़ा लाल टमाटर'),
    'onion': _Trans('લાલ ડુંગળી', 'लाल प्याज'),
    'cream': _Trans('તાજી મલાઈ / ક્રીમ', 'ताज़ी मलाई / क्रीम'),
    'butter': _Trans('અમૂલ માખણ / બટર', 'अमूल मक्खन / बटर'),
    'ginger': _Trans('આદુ-લસણની પેસ્ટ', 'अदरक-लहसुन का पेस्ट'),
    'garlic': _Trans('લસણની કળીઓ', 'लहसुन की कलियां'),
    'cashew': _Trans('કાજુના ટુકડા', 'काजू के टुकड़े'),
    'pouch': _Trans('જીરોલા મસાલા કિટ પાઉચ', 'जीरोला मसाला किट पाउच'),
    'mushroom': _Trans('બટન મશરૂમ', 'बटन मशरूम'),
    'green pea': _Trans('લીલા વટાણા', 'हरे मटर'),
    'vatana': _Trans('તાજા લીલા વટાણા', 'ताज़ा हरे मटर'),
    'oil': _Trans('શુદ્ધ સીંગતેલ / કુકિંગ ઓઇલ', 'शुद्ध मूंगफली का तेल / रिफाइंड'),
    'bell pepper': _Trans('શિમલા મરચાં (કેપ્સિકમ)', 'शिमला मिर्च (कैप्सिकम)'),
    'capsicum': _Trans('લીલા કેપ્સિકમ', 'हरी शिमला मिर्च'),
    'toor dal': _Trans('તુવેર દાળ', 'अरहर (तूर) दाल'),
    'chana dal': _Trans('ચણા દાળ', 'चना दाल'),
    'moong dal': _Trans('મગની ફોતરાં વગરની દાળ', 'मूंग दाल'),
    'ghee': _Trans('શુદ્ધ દેશી ગાયનું ઘી', 'शुद्ध देसी गाय का घी'),
    'rice': _Trans('બાસમતી ચોખા', 'बासमती चावल'),
    'curd': _Trans('તાજું મોળું દહીં', 'ताज़ा गाढ़ा दही'),
    'yogurt': _Trans('મીઠું ઘાટું દહીં', 'ताज़ा मीठा दही'),
    'kuttu': _Trans('કુટ્ટુનો લોટ (બકવ્હીટ)', 'कुट्टू का आटा'),
    'potato': _Trans('બાફેલા બટાકા', 'उबले हुए आलू'),
    'batata': _Trans('બાફેલા બટાકાનો માવો', 'उबले आलू का मसाला'),
    'moraiyo': _Trans('મોરૈયો (સામો ચોખા)', 'समा के चावल (मोरैया)'),
    'samak': _Trans('સામો / સામાના ચોખા', 'समा के चावल'),
    'peanut': _Trans('શેકેલા સીંગદાણા', 'भुनी हुई मूंगफली'),
    'coconut': _Trans('તાજું છીણેલું નાળિયેર', 'ताज़ा कसा नारियल'),
    'sabudana': _Trans('સાબુદાણા (પલાળેલા)', 'साबूदाना (भीगा हुआ)'),
    'broccoli': _Trans('તાજી લીલી બ્રોકોલી', 'ताज़ी हरी ब्रोकली'),
    'singhara': _Trans('શીંગોડાનો લોટ', 'सिंघाड़े का आटा'),
    'rajgira': _Trans('રાજગરાનો લોટ', 'राजगीरा का आटा'),
    'besan': _Trans('ચણાનો લોટ (બેસન)', 'चने का आटा (बेसन)'),
    'mawa': _Trans('તાજો માવો (ખોયા)', 'ताज़ा मावा (खोया)'),
    'saffron': _Trans('કાશ્મીરી કેસરના તાંતણા', 'कश्मीरी केसर'),
    'sesame': _Trans('સફેદ તલ', 'सफेद तिल'),
    'til': _Trans('શેકેલા સફેદ તલ', 'भुने सफेद तिल'),
    'jaggery': _Trans('ઓર્ગેનિક ગોળ', 'देसी ऑर्गेनिक गुड़'),
    'sugar': _Trans('ખાંડ / સાકર', 'चीनी / शक्कर'),
    'almond': _Trans('કેલિફોર્નિયા બદામ', 'कैलिफोर्निया बादाम'),
    'badam': _Trans('બદામની પેસ્ટ / બદામ', 'बादाम का पेस्ट / बादाम'),
    'poha': _Trans('પાતળા પૌંઆ', 'पतले पोहे'),
    'pauva': _Trans('શેકેલા પાતળા પૌંઆ', 'भुने हुए पोहे'),
    'sev': _Trans('રતલામી સેવ / નાયલોન સેવ', 'रतलामी सेव / नायलॉन सेव'),
    'pav': _Trans('બેકરી લાદી પાઉં', 'ताज़ा लादी पाव'),
    'bread': _Trans('બ્રેડ સ્લાઇસ', 'ब्रेड स्लाइस'),
    'corn': _Trans('અમેરિકન સ્વીટ કોર્ન', 'स्वीट कॉर्न के दाने'),
    'cheese': _Trans('મોઝરેલા / પ્રોસેસ્ડ ચીઝ', 'मोज़ेरेला / प्रोसेस्ड चीज़'),
    'mozzarella': _Trans('મોઝરેલા ચીઝ', 'मोज़ेरेला चीज़'),
    'okra': _Trans('તાજી કુણી ભીંડી', 'ताज़ी कोमल भिंडी'),
    'bhindi': _Trans('ભીંડાના ટુકડા', 'कटी हुई भिंडी'),
    'boondi': _Trans('ખારી ક્રિસ્પી બુંદી', 'कुरकुरी बूंदी'),
    'mango': _Trans('હાફૂસ કેરીનો રસ / પલ્પ', 'हापुस आम का गूदा / पल्प'),
    'flour': _Trans('મેંદો / ઘઉંનો લોટ', 'मैदा / गेहूं का आटा'),
    'sprout': _Trans('ફણગાવેલા મગ', 'अंकुरित मूंग'),
    'soya': _Trans('સોયા લોટ', 'सोया आटा'),
    'gond': _Trans('ખાવાનો ગુંદર (ગુંદર)', 'खाने वाला गोंद'),
    'gundar': _Trans('તળેલો ગુંદર', 'तला हुआ गोंद'),
  };
}

class _Trans {
  final String gujarati;
  final String hindi;
  const _Trans(this.gujarati, this.hindi);
}

class _StepLoc {
  final String title;
  final String instruction;
  final String flame;
  final String proTip;
  const _StepLoc(this.title, this.instruction, this.flame, this.proTip);
}
