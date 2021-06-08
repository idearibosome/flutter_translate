
import 'package:flutter_translate/src/constants/constants.dart';

class Localization
{
    late Map<String, dynamic> _translations;
    late Map<String, dynamic> _fallbackTranslations;

    Localization._();

    static Localization? _instance;
    static Localization get instance => _instance ?? (_instance = Localization._());

    static void load(Map<String, dynamic> translations, {Map<String, dynamic> fallback})
    {
        instance._translations = translations;
        instance._fallbackTranslations = fallback;
    }

    String translate(String key, {Map<String, dynamic>? args})
    {
        var translation = _getTranslation(key, _translations, _fallbackTranslations);

        if (translation != null && args != null)
        {
            translation = _assignArguments(translation, args);
        }

        return translation ?? key;
    }

    String plural(String key, num value, {Map<String, dynamic>? args})
    {
        var pluralKeyValue = _getPluralKeyValue(value);
        var translation = _getPluralTranslation(key, pluralKeyValue, _translations, _fallbackTranslations);

        if(translation != null)
        {
            translation = translation.replaceAll(Constants.pluralValueArg, value.toString());

            if (args != null)
            {
                translation = _assignArguments(translation, args);
            }
        }

        return translation ?? '$key.$pluralKeyValue';
    }

    String _getPluralKeyValue(num value)
    {
        switch(value)
        {
            case 0: return Constants.pluralZero;
            case 1: return Constants.pluralOne;
            case 2: return Constants.pluralTwo;
            default: return Constants.pluralElse;
        }
    }

    String _assignArguments(String value, Map<String, dynamic> args)
    {
        for(final key in args.keys)
        {
            value = value.replaceAll('{$key}', '${args[key]}');
        }

        return value;
    }

    String? _getTranslation(String key, Map<String, dynamic> map, Map<String, dynamic> fallbackMap)
    {
        List<String> keys = key.split('.');

        if (keys.length > 1)
        {
            var firstKey = keys.first;
            var remainingKey = key.substring(key.indexOf('.') + 1);

            var value = map[firstKey];
            if (value != null && value is! String)
            {
                return _getTranslation(remainingKey, value, fallbackMap != null ? fallbackMap[firstKey] : null);
            } else if (fallbackMap != null)
            {
                var fallbackValue = fallbackMap[firstKey];
                if (fallbackValue != null && fallbackValue is! String)
                {
                    return _getTranslation(remainingKey, fallbackValue, null);
                }
            }
        }

        return map[key] ?? (fallbackMap != null ? fallbackMap[key] : null);
    }

    String? _getPluralTranslation(String key, String valueKey, Map<String, dynamic> map, Map<String, dynamic> fallbackMap)
    {
        List<String> keys = key.split('.');

        if (keys.length > 1)
        {
            var firstKey = keys.first;

            if(map.containsKey(firstKey) && map[firstKey] is! String)
            {
                return _getPluralTranslation(key.substring(key.indexOf('.') + 1), valueKey, map[firstKey], fallbackMap != null ? fallbackMap[firstKey] : null);
            }
            else if (fallbackMap != null) {
                if (fallbackMap.containsKey(firstKey) && fallbackMap[firstKey] is! String) {
                    return _getPluralTranslation(key.substring(key.indexOf('.') + 1), valueKey, fallbackMap[firstKey], null);
                }
            }
        }

        if (map[key] != null) return map[key][valueKey] ?? map[key][Constants.pluralElse];
        else return fallbackMap[key][valueKey] ?? fallbackMap[key][Constants.pluralElse];
    }
}
