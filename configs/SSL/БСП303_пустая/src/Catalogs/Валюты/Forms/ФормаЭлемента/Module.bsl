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
	
	Если Объект.Ссылка.Пустая() Тогда
		
		Если Параметры.Свойство("КодВалюты") Тогда
			Объект.Код = Параметры.КодВалюты;
		КонецЕсли;
		
		Если Параметры.Свойство("НаименованиеКраткое") Тогда
			Объект.Наименование = Параметры.НаименованиеКраткое;
		КонецЕсли;
		
		Если Параметры.Свойство("НаименованиеПолное") Тогда
			Объект.НаименованиеПолное = Параметры.НаименованиеПолное;
		КонецЕсли;
		
		Если Параметры.Свойство("Загружается") И Параметры.Загружается Тогда
			Объект.СпособУстановкиКурса = Перечисления.СпособыУстановкиКурсаВалюты.ЗагрузкаИзИнтернета;
		Иначе 
			Объект.СпособУстановкиКурса = Перечисления.СпособыУстановкиКурсаВалюты.РучнойВвод;
		КонецЕсли;
		
		Если Параметры.Свойство("ПараметрыПрописи") Тогда
			Объект.ПараметрыПрописи = Параметры.ПараметрыПрописи;
		КонецЕсли;
		
	КонецЕсли;
	
	ОбработкаЗагрузкаКурсовВалют = Метаданные.Обработки.Найти("ЗагрузкаКурсовВалют");
	Если ОбработкаЗагрузкаКурсовВалют <> Неопределено Тогда
		ЕстьФормаПараметрыПрописиВалюты = ОбработкаЗагрузкаКурсовВалют.Формы.Найти("ПараметрыПрописиВалюты") <> Неопределено;
	КонецЕсли;
	
	Элементы.КурсВалютыЗагружаетсяИзИнтернета.Видимость = ОбработкаЗагрузкаКурсовВалют <> Неопределено;
	УстановитьДоступностьЭлементов(ЭтотОбъект);
	
	Если ОбщегоНазначения.ЭтоМобильныйКлиент() Тогда
		Элементы.ФормулаРасчетаКурса.ОтображениеПодсказки = ОтображениеПодсказки.ОтображатьСнизу;
		Элементы.ОсновнаяВалюта.ПоложениеЗаголовка = ПоложениеЗаголовкаЭлементаФормы.Авто;
		Элементы.ГруппаШапка.ВыравниваниеЭлементовИЗаголовков =
			ВариантВыравниванияЭлементовИЗаголовков.ЭлементыПравоЗаголовкиЛево;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

////////////////////////////////////////////////////////////////////////////////
// Страница "Основные сведения".

&НаКлиенте
Процедура ОсновнаяВалютаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ПодготовитьДанныеВыбораПодчиненнойВалюты(ДанныеВыбора, Объект.Ссылка);
	
КонецПроцедуры

&НаКлиенте
Процедура КурсВалютыПриИзменении(Элемент)
	УстановитьДоступностьЭлементов(ЭтотОбъект);
КонецПроцедуры

&НаКлиенте
Процедура ПараметрыПрописиВалютыНажатие(Элемент)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПриИзмененииПараметровПрописиВалюты", ЭтотОбъект);
	Если ЕстьФормаПараметрыПрописиВалюты Тогда
		ПараметрыОткрытия = Новый Структура;
		ПараметрыОткрытия.Вставить("ТолькоПросмотр", ТолькоПросмотр);
		ПараметрыОткрытия.Вставить("ПараметрыПрописи", Объект.ПараметрыПрописи);
		ИмяФормыРедактированияПрописей = "Обработка.ЗагрузкаКурсовВалют.Форма.ПараметрыПрописиВалюты";
		ОткрытьФорму(ИмяФормыРедактированияПрописей, ПараметрыОткрытия, ЭтотОбъект, , , , ОписаниеОповещения);
	Иначе
		ПоказатьВводСтроки(ОписаниеОповещения, Объект.ПараметрыПрописи, НСтр("ru = 'Параметры прописи валюты'"));
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
Процедура ПодготовитьДанныеВыбораПодчиненнойВалюты(ДанныеВыбора, Ссылка)
	
	// Подготавливает список выбора для подчиненной валюты таким образом,
	// чтобы в список не попала сама подчиненная валюта.
	
	ДанныеВыбора = Новый СписокЗначений;
	
	Запрос = Новый Запрос;
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Валюты.Ссылка КАК Ссылка,
	|	Валюты.НаименованиеПолное КАК НаименованиеПолное,
	|	Валюты.Наименование КАК Наименование
	|ИЗ
	|	Справочник.Валюты КАК Валюты
	|ГДЕ
	|	Валюты.Ссылка <> &Ссылка
	|	И Валюты.ОсновнаяВалюта = ЗНАЧЕНИЕ(Справочник.Валюты.ПустаяСсылка)
	|
	|УПОРЯДОЧИТЬ ПО
	|	Валюты.НаименованиеПолное";
	
	Запрос.Параметры.Вставить("Ссылка", Ссылка);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		ДанныеВыбора.Добавить(Выборка.Ссылка, Выборка.НаименованиеПолное + " (" + Выборка.Наименование + ")");
	КонецЦикла;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьДоступностьЭлементов(Форма)
	Элементы = Форма.Элементы;
	Объект = Форма.Объект;
	Элементы.ГруппаНаценкаНаКурсДругойВалюты.Доступность = Объект.СпособУстановкиКурса = ПредопределенноеЗначение("Перечисление.СпособыУстановкиКурсаВалюты.НаценкаНаКурсДругойВалюты");
	Элементы.ФормулаРасчетаКурса.Доступность = Объект.СпособУстановкиКурса = ПредопределенноеЗначение("Перечисление.СпособыУстановкиКурсаВалюты.РасчетПоФормуле");
КонецПроцедуры

&НаКлиенте
Процедура ПриИзмененииПараметровПрописиВалюты(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Объект.ПараметрыПрописи = Результат;
	Модифицированность = Истина;
КонецПроцедуры

#КонецОбласти
