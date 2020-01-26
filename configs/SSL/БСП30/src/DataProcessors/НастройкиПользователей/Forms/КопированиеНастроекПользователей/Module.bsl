///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ИспользоватьВнешнихПользователей = ПолучитьФункциональнуюОпцию("ИспользоватьВнешнихПользователей");
	ПереключательКомуКопироватьНастройки = "ВыбраннымПользователям";
	ПереключательКопируемыеНастройки = "СкопироватьВсе";
	РежимОткрытияФормы = Параметры.РежимОткрытияФормы;
	
	ПользователиПолучателиНастроек = Новый Структура;
	Если Параметры.Пользователь <> Неопределено Тогда
		МассивПользователей = Новый Массив;
		МассивПользователей.Добавить(Параметры.Пользователь);
		ПользователиПолучателиНастроек.Вставить("МассивПользователей", МассивПользователей);
		Элементы.ВыбратьПользователей.Заголовок = Строка(Параметры.Пользователь);
		КоличествоПользователей = 1;
		ТипПереданногоПользователя = ТипЗнч(Параметры.Пользователь);
		Элементы.ГруппаКомуКопировать.Доступность = Ложь;
	Иначе
		ПользовательСсылка = Пользователи.ТекущийПользователь();
	КонецЕсли;
	
	Если ПользовательСсылка = Неопределено Тогда
		Элементы.ГруппаКопируемыеНастройки.Доступность = Ложь;
	КонецЕсли;
	
	ОчиститьИсториюВыбораНастроек = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ВРег(ИмяСобытия) = ВРег("ВыборПользователя") Тогда
		ПользователиПолучателиНастроек = Новый Структура("МассивПользователей", Параметр.ПользователиПриемник);
		
		КоличествоПользователей = Параметр.ПользователиПриемник.Количество();
		Если КоличествоПользователей = 1 Тогда
			Элементы.ВыбратьПользователей.Заголовок = Строка(Параметр.ПользователиПриемник[0]);
		ИначеЕсли КоличествоПользователей > 1 Тогда
			ЧислоИПредмет = Формат(КоличествоПользователей, "ЧДЦ=0") + " "
				+ ПользователиСлужебныйКлиентСервер.ПредметЦелогоЧисла(КоличествоПользователей,
					"", НСтр("ru = 'пользователь,пользователя,пользователей,,,,,,0'"));
			Элементы.ВыбратьПользователей.Заголовок = ЧислоИПредмет;
		КонецЕсли;
		Элементы.ВыбратьПользователей.Подсказка = "";
		
	ИначеЕсли ВРег(ИмяСобытия) = ВРег("СкопироватьНастройкиАктивнымПользователям") Тогда
		
		СкопироватьНастройки(Параметр.Действие);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПользовательНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ВыбранныйТипПользователей = Неопределено;
	
	Если КоличествоПользователей <> 0 Тогда
		СкрываемыеПользователи = Новый СписокЗначений;
		СкрываемыеПользователи.ЗагрузитьЗначения(ПользователиПолучателиНастроек.МассивПользователей);
	КонецЕсли;
	
	ПараметрыОтбора = Новый Структура(
		"РежимВыбора, СкрываемыеПользователи",
		Истина, СкрываемыеПользователи);
	
	Если ТипПереданногоПользователя = Неопределено Тогда
		
		Если ИспользоватьВнешнихПользователей Тогда
			ВыборТипаПользователей = Новый СписокЗначений;
			ВыборТипаПользователей.Добавить("ВнешниеПользователи", НСтр("ru = 'Внешние пользователи'"));
			ВыборТипаПользователей.Добавить("Пользователи", НСтр("ru = 'Пользователи'"));
			
			Оповещение = Новый ОписаниеОповещения("ПользовательНачалоВыбораЗавершение", ЭтотОбъект, ПараметрыОтбора);
			ВыборТипаПользователей.ПоказатьВыборЭлемента(Оповещение);
			Возврат;
		Иначе
			ВыбранныйТипПользователей = "Пользователи";
		КонецЕсли;
		
	КонецЕсли;
	
	ОткрытьФормуВыбораПользователей(ВыбранныйТипПользователей, ПараметрыОтбора);
	
КонецПроцедуры

&НаКлиенте
Процедура ПользовательНачалоВыбораЗавершение(ВыбранныйВариант, ПараметрыОтбора) Экспорт
	
	Если ВыбранныйВариант = Неопределено Тогда
		Возврат;
	КонецЕсли;
	ВыбранныйТипПользователей = ВыбранныйВариант.Значение;
	
	ОткрытьФормуВыбораПользователей(ВыбранныйТипПользователей, ПараметрыОтбора);
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьФормуВыбораПользователей(ВыбранныйТипПользователей, ПараметрыОтбора)
	
	Если ВыбранныйТипПользователей = "Пользователи"
		Или ТипПереданногоПользователя = Тип("СправочникСсылка.Пользователи") Тогда
		ОткрытьФорму("Справочник.Пользователи.Форма.ФормаСписка", ПараметрыОтбора, Элементы.ПользовательСсылка);
	ИначеЕсли ВыбранныйТипПользователей = "ВнешниеПользователи"
		Или ТипПереданногоПользователя = Тип("СправочникСсылка.ВнешниеПользователи") Тогда
		ОткрытьФорму("Справочник.ВнешниеПользователи.Форма.ФормаСписка", ПараметрыОтбора, Элементы.ПользовательСсылка);
	КонецЕсли;
	ПользовательСсылкаСтарый = ПользовательСсылка;
	
КонецПроцедуры

&НаКлиенте
Процедура ПользовательСсылкаПриИзменении(Элемент)
	
	Если ПользовательСсылка <> Неопределено
		И ИмяПользователяИБ(ПользовательСсылка) = Неопределено Тогда
		ПоказатьПредупреждение(,НСтр("ru = 'У выбранного пользователя нет настроек, которые можно было бы
				|скопировать, выберите другого пользователя.'"));
		ПользовательСсылка = ПользовательСсылкаСтарый;
		Возврат;
	КонецЕсли;
	
	Если ПользовательСсылка <> Неопределено
		И ПользователиПолучателиНастроек.Свойство("МассивПользователей") Тогда
		
		Если ПользователиПолучателиНастроек.МассивПользователей.Найти(ПользовательСсылка) <> Неопределено Тогда
			ПоказатьПредупреждение(,НСтр("ru = 'Нельзя копировать настройки пользователя самому себе,
					|выберите другого пользователя.'"));
				ПользовательСсылка = ПользовательСсылкаСтарый;
				Возврат;
		КонецЕсли;
		
	КонецЕсли;
	
	Элементы.ГруппаКопируемыеНастройки.Доступность = ПользовательСсылка <> Неопределено;
	
	ВыбранныеНастройки = Неопределено;
	КоличествоНастроек = 0;
	Элементы.ВыбратьНастройки.Заголовок = НСтр("ru='Выбрать'");
	
КонецПроцедуры

&НаСервере
Функция ИмяПользователяИБ(ПользовательСсылка)
	
	Возврат Обработки.НастройкиПользователей.ИмяПользователяИБ(ПользовательСсылка);
	
КонецФункции

&НаКлиенте
Процедура ВыбратьНастройки(Элемент)
	
	ПараметрыФормы = Новый Структура("Пользователь, ДействиеСНастройками, ОчиститьИсториюВыбораНастроек",
		ПользовательСсылка, "Копирование", ОчиститьИсториюВыбораНастроек);
	ОткрытьФорму("Обработка.НастройкиПользователей.Форма.ВыборНастроек", ПараметрыФормы, ЭтотОбъект,,,,
		Новый ОписаниеОповещения("ВыбратьНастройкиПослеВыбора", ЭтотОбъект));
	
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьПользователей(Элемент)
	
	ВыбранныеПользователи = Неопределено;
	ПользователиПолучателиНастроек.Свойство("МассивПользователей", ВыбранныеПользователи);
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("Пользователь",          ПользовательСсылка);
	ПараметрыФормы.Вставить("ТипДействия",           "Копирование");
	ПараметрыФормы.Вставить("ВыбранныеПользователи", ВыбранныеПользователи);
	
	ОткрытьФорму("Обработка.НастройкиПользователей.Форма.ВыборПользователей", ПараметрыФормы);
	
КонецПроцедуры

&НаКлиенте
Процедура ПереключательКомуКопироватьНастройкиПриИзменении(Элемент)
	
	Если ПереключательКомуКопироватьНастройки = "ВыбраннымПользователям" Тогда
		Элементы.ВыбратьПользователей.Доступность = Истина;
	Иначе
		Элементы.ВыбратьПользователей.Доступность = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПереключательКопируемыеНастройкиПриИзменении(Элемент)
	
	Если ПереключательКопируемыеНастройки = "СкопироватьОтдельные" Тогда
		Элементы.ВыбратьНастройки.Доступность = Истина;
	Иначе
		Элементы.ВыбратьНастройки.Доступность = Ложь;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Скопировать(Команда)
	
	ОчиститьСообщения();
	
	Если ПользовательСсылка = Неопределено Тогда
		ОбщегоНазначенияКлиент.СообщитьПользователю(
			НСтр("ru = 'Выберите пользователя, чьи настройки необходимо скопировать.'"), , "ПользовательСсылка");
		Возврат;
	КонецЕсли;
	
	Если КоличествоПользователей = 0 И ПереключательКомуКопироватьНастройки <> "ВсемПользователям" Тогда
		ОбщегоНазначенияКлиент.СообщитьПользователю(
			НСтр("ru = 'Выберите одного или несколько пользователей, которым необходимо скопировать настройки.'"), , "Приемник");
		Возврат;
	КонецЕсли;
	
	Если ПереключательКопируемыеНастройки = "СкопироватьОтдельные" И КоличествоНастроек = 0 Тогда
		ОбщегоНазначенияКлиент.СообщитьПользователю(
			НСтр("ru = 'Выберите настройки, которые необходимо скопировать.'"), , "ПереключательКопируемыеНастройки");
		Возврат;
	КонецЕсли;
	
	// При копировании настроек внешнего вида или всех настроек другим пользователям
	// проверяем работают они с программой или нет. Если работают - выводим сообщение об этом.
	ОткрытыеКопируемыеФормы = ОткрытыеКопируемыеФормы();
	ПроверитьАктивныхПользователей();
	Если РезультатПроверки = "ЕстьАктивныеПользователиПолучатели"
		Или ЗначениеЗаполнено(ОткрытыеКопируемыеФормы) Тогда
		
		Если ПереключательКопируемыеНастройки = "СкопироватьВсе" 
			Или (ПереключательКопируемыеНастройки = "СкопироватьОтдельные"
			И ВыбранныеНастройки.ВнешнийВид.Количество() <> 0) Тогда
			
			ПараметрыФормы = Новый Структура;
			ПараметрыФормы.Вставить("Действие", Команда.Имя);
			ПараметрыФормы.Вставить("ОткрытыеКопируемыеФормы", ОткрытыеКопируемыеФормы);
			ПараметрыФормы.Вставить("ЕстьАктивныеПользователиПолучатели", РезультатПроверки = "ЕстьАктивныеПользователиПолучатели");
			ОткрытьФорму("Обработка.НастройкиПользователей.Форма.ПредупреждениеОКопированииНастроек", ПараметрыФормы);
			Возврат;
			
		КонецЕсли;
		
	КонецЕсли;
	СкопироватьНастройки(Команда.Имя);
	
КонецПроцедуры

&НаКлиенте
Функция ОткрытыеКопируемыеФормы()
	
	Если ВыбранныеНастройки = Неопределено Тогда
		Возврат "";
	КонецЕсли;
	Настройки = ВыбранныеНастройки.ВнешнийВид;
	
	СтрокаОткрытыеФормы          = "";
	СтрокаВсеКопируемыеНастройки = "";
	Для Каждого НастройкиФормы Из Настройки Цикл
		Для Каждого НастройкаФормы Из НастройкиФормы Цикл
			СтрокаВсеКопируемыеНастройки = СтрокаВсеКопируемыеНастройки + Символы.ПС + НастройкаФормы.Значение;
		КонецЦикла;
	КонецЦикла;
	
	ОткрытыеОкна = ПолучитьОкна();
	Для Каждого ОткрытоеОкно Из ОткрытыеОкна Цикл
		Если ОткрытоеОкно.НачальнаяСтраница Или ОткрытоеОкно.Основное Тогда
			Продолжить;
		КонецЕсли;
		Содержимое    = ОткрытоеОкно.Содержимое;
		ОсновнаяФорма = Содержимое.Получить(0);
		
		ИмяОткрытойФормы = ОсновнаяФорма.ИмяФормы;
		Если СтрНайти(ИмяОткрытойФормы, "Обработка.НастройкиПользователей") > 0
			Или СтрНайти(ИмяОткрытойФормы, ".ПанельАдминистрированияБСП.") > 0 Тогда
			Продолжить;
		КонецЕсли;
		
		Если СтрНайти(СтрокаВсеКопируемыеНастройки, ИмяОткрытойФормы) > 0 Тогда
			СтрокаОткрытыеФормы = ?(ЗначениеЗаполнено(СтрокаОткрытыеФормы),
				СтрокаОткрытыеФормы + Символы.ПС + "- " + ОткрытоеОкно.Заголовок,
				НСтр("ru = 'Открытые окна'") + ":" + Символы.ПС + "- " + ОткрытоеОкно.Заголовок)
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат СтрокаОткрытыеФормы;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ВыбратьНастройкиПослеВыбора(Параметр, Контекст) Экспорт
	
	Если ТипЗнч(Параметр) <> Тип("Структура") Тогда
		Возврат;
	КонецЕсли;
	
	ВыбранныеНастройки = Новый Структура;
	ВыбранныеНастройки.Вставить("ВнешнийВид",       Параметр.ВнешнийВид);
	ВыбранныеНастройки.Вставить("НастройкиОтчетов", Параметр.НастройкиОтчетов);
	ВыбранныеНастройки.Вставить("ПрочиеНастройки",  Параметр.ПрочиеНастройки);
	
	ВыбранныеНастройки.Вставить("ТаблицаВариантовОтчетов",  Параметр.ТаблицаВариантовОтчетов);
	ВыбранныеНастройки.Вставить("ВыбранныеВариантыОтчетов", Параметр.ВыбранныеВариантыОтчетов);
	
	ВыбранныеНастройки.Вставить("ПерсональныеНастройки",           Параметр.ПерсональныеНастройки);
	ВыбранныеНастройки.Вставить("ПрочиеПользовательскиеНастройки", Параметр.ПрочиеПользовательскиеНастройки);
	
	КоличествоНастроек = Параметр.КоличествоНастроек;
	
	Если КоличествоНастроек = 0 Тогда
		ТекстЗаголовка = НСтр("ru='Выбрать'");
	ИначеЕсли КоличествоНастроек = 1 Тогда
		ПредставлениеНастройки = Параметр.ПредставленияНастроек[0];
		ТекстЗаголовка = ПредставлениеНастройки;
	Иначе
		ТекстЗаголовка = Формат(КоличествоНастроек, "ЧДЦ=0") + " "
			+ ПользователиСлужебныйКлиентСервер.ПредметЦелогоЧисла(КоличествоНастроек,
				"", НСтр("ru = 'настройка,настройки,настроек,,,,,,0'"));
	КонецЕсли;
	
	Элементы.ВыбратьНастройки.Заголовок = ТекстЗаголовка;
	Элементы.ВыбратьНастройки.Подсказка = "";
	
КонецПроцедуры

&НаКлиенте
Процедура СкопироватьНастройки(ИмяКоманды)
	
	Если ПереключательКомуКопироватьНастройки = "ВыбраннымПользователям" Тогда
		
		ПояснениеКомуСкопированыНастройки = ПользователиСлужебныйКлиент.ПояснениеПользователи(
			КоличествоПользователей, ПользователиПолучателиНастроек.МассивПользователей[0]);
	Иначе
		ПояснениеКомуСкопированыНастройки = НСтр("ru = 'всем пользователям'");
	КонецЕсли;
	
	ТекстОповещения    = НСтр("ru = 'Копирование настроек'");
	КартинкаОповещения = БиблиотекаКартинок.Информация32;
	
	Если ПереключательКопируемыеНастройки = "СкопироватьОтдельные" Тогда
		Отчет = Неопределено;
		СкопироватьВыбранныеНастройки(Отчет);
		
		Если Отчет <> Неопределено Тогда
			ТекстВопроса = НСтр("ru = 'Не все варианты отчетов и настройки были скопированы.'");
			КнопкиВопроса = Новый СписокЗначений;
			КнопкиВопроса.Добавить("Ок", НСтр("ru = 'ОК'"));
			КнопкиВопроса.Добавить("ПоказатьОтчет", НСтр("ru = 'Показать отчет'"));
			
			Оповещение = Новый ОписаниеОповещения("СкопироватьНастройкиПоказатьВопрос", ЭтотОбъект, Отчет);
			ПоказатьВопрос(Оповещение, ТекстВопроса, КнопкиВопроса,, КнопкиВопроса[0].Значение);
			Возврат;
		КонецЕсли;
			
		Если Отчет = Неопределено Тогда
			ПояснениеОповещения = ПользователиСлужебныйКлиент.ФормированиеПоясненияПриКопировании(
				ПредставлениеНастройки, КоличествоНастроек, ПояснениеКомуСкопированыНастройки);
			
			ПоказатьОповещениеПользователя(ТекстОповещения, , ПояснениеОповещения, КартинкаОповещения);
		КонецЕсли;
	Иначе
		НастройкиСкопированы = КопированиеВсехНастроек();
		Если Не НастройкиСкопированы Тогда
			
			ПоказатьПредупреждение(, СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Настройки не были скопированы, так как у пользователя ""%1"" не было сохранено ни одной настройки.'"),
				Строка(ПользовательСсылка)));
			Возврат;
		КонецЕсли;
		
		ПояснениеОповещения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Скопированы все настройки %1'"), ПояснениеКомуСкопированыНастройки);
		
		ПоказатьОповещениеПользователя(ТекстОповещения, , ПояснениеОповещения, КартинкаОповещения);
	КонецЕсли;
	
	// Если копирование настроек от другого пользователя, оповещаем об этом форму НастройкиПользователей.
	Если РежимОткрытияФормы = "СкопироватьОт" Тогда
		Оповестить("СкопированыНастройки", Истина);
	КонецЕсли;
	
	Если ИмяКоманды = "СкопироватьИЗакрыть" Тогда
		Закрыть();
	КонецЕсли;
	
	Возврат;
	
КонецПроцедуры

&НаКлиенте
Процедура СкопироватьНастройкиПоказатьВопрос(Ответ, Отчет) Экспорт
	
	Если Ответ = "Ок" Тогда
		Возврат;
	Иначе
		Отчет.ОтображатьГруппировки = Истина;
		Отчет.ОтображатьСетку = Ложь;
		Отчет.ОтображатьЗаголовки = Ложь;
		Отчет.Показать();
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура СкопироватьВыбранныеНастройки(Отчет)
	
	Пользователь = Обработки.НастройкиПользователей.ИмяПользователяИБ(ПользовательСсылка);
	
	Если ПереключательКомуКопироватьНастройки = "ВыбраннымПользователям" Тогда
		Приемники = ПользователиПолучателиНастроек.МассивПользователей;
	ИначеЕсли ПереключательКомуКопироватьНастройки = "ВсемПользователям" Тогда
		Приемники = Новый Массив;
		ТаблицаПользователей = Новый ТаблицаЗначений;
		ТаблицаПользователей.Колонки.Добавить("Пользователь");
		Обработки.НастройкиПользователей.ПользователиДляКопирования(ПользовательСсылка, ТаблицаПользователей,
			ТипЗнч(ПользовательСсылка) = Тип("СправочникСсылка.ВнешниеПользователи"));
		
		Для Каждого СтрокаТаблицы Из ТаблицаПользователей Цикл
			Приемники.Добавить(СтрокаТаблицы.Пользователь);
		КонецЦикла;
		
	КонецЕсли;
	
	НеСкопированныеНастройкиОтчетов = Новый ТаблицаЗначений;
	НеСкопированныеНастройкиОтчетов.Колонки.Добавить("Пользователь");
	НеСкопированныеНастройкиОтчетов.Колонки.Добавить("СписокОтчетов", Новый ОписаниеТипов("СписокЗначений"));
	
	Если ВыбранныеНастройки.НастройкиОтчетов.Количество() > 0 Тогда
		
		Обработки.НастройкиПользователей.СкопироватьНастройкиОтчетовИПерсональныеНастройки(ХранилищеПользовательскихНастроекОтчетов,
			Пользователь, Приемники, ВыбранныеНастройки.НастройкиОтчетов, НеСкопированныеНастройкиОтчетов);
		
		Обработки.НастройкиПользователей.СкопироватьВариантыОтчетов(
			ВыбранныеНастройки.ВыбранныеВариантыОтчетов, ВыбранныеНастройки.ТаблицаВариантовОтчетов, Пользователь, Приемники);
	КонецЕсли;
		
	Если ВыбранныеНастройки.ВнешнийВид.Количество() > 0 Тогда
		Обработки.НастройкиПользователей.СкопироватьНастройкиВнешнегоВида(Пользователь, Приемники, ВыбранныеНастройки.ВнешнийВид);
	КонецЕсли;
	
	Если ВыбранныеНастройки.ПрочиеНастройки.Количество() > 0 Тогда
		Обработки.НастройкиПользователей.СкопироватьНастройкиВнешнегоВида(Пользователь, Приемники, ВыбранныеНастройки.ПрочиеНастройки);
	КонецЕсли;
	
	Если ВыбранныеНастройки.ПерсональныеНастройки.Количество() > 0 Тогда
		Обработки.НастройкиПользователей.СкопироватьНастройкиОтчетовИПерсональныеНастройки(ХранилищеОбщихНастроек,
			Пользователь, Приемники, ВыбранныеНастройки.ПерсональныеНастройки);
	КонецЕсли;
	
	Для Каждого ПрочаяНастройкаПользователя Из ВыбранныеНастройки.ПрочиеПользовательскиеНастройки Цикл
		Для Каждого ПользовательСправочника Из Приемники Цикл
			СведенияОПользователе = Новый Структура;
			СведенияОПользователе.Вставить("ПользовательСсылка", ПользовательСправочника);
			СведенияОПользователе.Вставить("ИмяПользователяИнформационнойБазы", 
				Обработки.НастройкиПользователей.ИмяПользователяИБ(ПользовательСправочника));
			ПользователиСлужебный.ПриСохраненииПрочихНастроекПользователя(
				СведенияОПользователе, ПрочаяНастройкаПользователя);
		КонецЦикла;
	КонецЦикла;
	
	Если НеСкопированныеНастройкиОтчетов.Количество() <> 0 Тогда
		Отчет = Обработки.НастройкиПользователей.ФормированиеОтчетаОКопировании(
			НеСкопированныеНастройкиОтчетов);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция КопированиеВсехНастроек()
	
	Если ПереключательКомуКопироватьНастройки = "ВыбраннымПользователям" Тогда
		Приемники = ПользователиПолучателиНастроек.МассивПользователей;
	Иначе
		Приемники = Новый Массив;
		ТаблицаПользователей = Новый ТаблицаЗначений;
		ТаблицаПользователей.Колонки.Добавить("Пользователь");
		ТаблицаПользователей = Обработки.НастройкиПользователей.ПользователиДляКопирования(ПользовательСсылка, ТаблицаПользователей, 
			ТипЗнч(ПользовательСсылка) = Тип("СправочникСсылка.ВнешниеПользователи"));
		
		Для Каждого СтрокаТаблицы Из ТаблицаПользователей Цикл
			Приемники.Добавить(СтрокаТаблицы.Пользователь);
		КонецЦикла;
		
	КонецЕсли;
	
	КопируемыеНастройки = Новый Массив;
	КопируемыеНастройки.Добавить("НастройкиОтчетов");
	КопируемыеНастройки.Добавить("НастройкиВнешнегоВида");
	КопируемыеНастройки.Добавить("ПерсональныеНастройки");
	КопируемыеНастройки.Добавить("Избранное");
	КопируемыеНастройки.Добавить("НастройкиПечати");
	КопируемыеНастройки.Добавить("ПрочиеПользовательскиеНастройки");
	
	НастройкиСкопированы = Обработки.НастройкиПользователей.
		КопированиеНастроекПользователей(ПользовательСсылка, Приемники, КопируемыеНастройки);
		
	Возврат НастройкиСкопированы;
	
КонецФункции

&НаСервере
Процедура ПроверитьАктивныхПользователей()
	
	ТекущийПользователь = Пользователи.ТекущийПользователь();
	Если ПользователиПолучателиНастроек.Свойство("МассивПользователей") Тогда
		МассивПользователей = ПользователиПолучателиНастроек.МассивПользователей;
	КонецЕсли;
	
	Если ПереключательКомуКопироватьНастройки = "ВсемПользователям" Тогда
		
		МассивПользователей = Новый Массив;
		ТаблицаПользователей = Новый ТаблицаЗначений;
		ТаблицаПользователей.Колонки.Добавить("Пользователь");
		ТаблицаПользователей = Обработки.НастройкиПользователей.ПользователиДляКопирования(ПользовательСсылка, ТаблицаПользователей, 
			ТипЗнч(ПользовательСсылка) = Тип("СправочникСсылка.ВнешниеПользователи"));
		
		Для Каждого СтрокаТаблицы Из ТаблицаПользователей Цикл
			МассивПользователей.Добавить(СтрокаТаблицы.Пользователь);
		КонецЦикла;
		
	КонецЕсли;
	
	Если МассивПользователей.Количество() = 1 
		И МассивПользователей[0] = ТекущийПользователь Тогда
		
		РезультатПроверки = "ТекущийПользовательПолучатель";
		Возврат;
		
	КонецЕсли;
		
	ЕстьАктивныеПользователиПолучатели = Ложь;
	Сеансы = ПолучитьСеансыИнформационнойБазы();
	Для Каждого Получатель Из МассивПользователей Цикл
		Если Получатель = ТекущийПользователь Тогда
			РезультатПроверки = "ТекущийПользовательСредиПолучателей";
			Возврат;
		КонецЕсли;
		Для Каждого Сеанс Из Сеансы Цикл
			Если Получатель.ИдентификаторПользователяИБ = Сеанс.Пользователь.УникальныйИдентификатор Тогда
				ЕстьАктивныеПользователиПолучатели = Истина;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	РезультатПроверки = ?(ЕстьАктивныеПользователиПолучатели, "ЕстьАктивныеПользователиПолучатели", "");
	
КонецПроцедуры

#КонецОбласти
