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
	
	ОбработатьВходящиеПараметры(Отказ);
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	ШаблонЗаголовка =  НСтр("ru = 'Ответы на вопрос № %1 опроса %2 +  от %3.'");
	Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонЗаголовка, ПолныйКод, НаименованиеОпроса, Формат(ДатаОпроса,"ДЛФ=D"));
	
	СформироватьОтчет();
	
КонецПроцедуры

&НаКлиенте
Процедура ВариантОтчетаПриИзменении(Элемент)
	
	СформироватьОтчет();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура СформироватьОтчет()
	
	ТаблицаОтчета.Очистить();
	СКД = Отчеты.АнализОпроса.ПолучитьМакет("ПростыеВопросы");
	Настройки = СКД.ВариантыНастроек[ВариантОтчета].Настройки;
	
	СКД.Параметры.ВопросШаблонаАнкеты.Значение = ВопросШаблонаАнкеты;
	СКД.Параметры.Опрос.Значение               = Опрос;
	
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновки = КомпоновщикМакета.Выполнить(СКД,Настройки);
	
	ПроцессорКомпоновкиДанных = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновкиДанных.Инициализировать(МакетКомпоновки);
	
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(ТаблицаОтчета);
	ПроцессорВывода.Вывести(ПроцессорКомпоновкиДанных);
	
	ТаблицаОтчета.ОтображатьСетку = Ложь;
	ТаблицаОтчета.ОтображатьЗаголовки = Ложь;
	
КонецПроцедуры

// Обрабатывает входящие параметры формы.
//
// Возвращаемое значение:
//   Булево - отказ от запуска формы.
//
&НаСервере
Процедура ОбработатьВходящиеПараметры(Отказ)

	Если Параметры.Свойство("ВопросШаблонаАнкеты") Тогда	
		ВопросШаблонаАнкеты = Параметры.ВопросШаблонаАнкеты; 
	Иначе
		Отказ = Истина;
	КонецЕсли;
	
	Если Параметры.Свойство("Опрос") Тогда
		Опрос =  Параметры.Опрос; 
	Иначе
		Отказ = Истина;
	КонецЕсли;
	
	Если Параметры.Свойство("ПолныйКод") Тогда
		ПолныйКод =  Параметры.ПолныйКод;
	Иначе
		Отказ = Истина;
	КонецЕсли;
	
	Если Параметры.Свойство("НаименованиеОпроса") Тогда
		НаименованиеОпроса =  Параметры.НаименованиеОпроса;
	Иначе
		Отказ = Истина;
	КонецЕсли;
	
	Если Параметры.Свойство("ДатаОпроса") Тогда
		ДатаОпроса =  Параметры.ДатаОпроса;
	Иначе
		Отказ = Истина;
	КонецЕсли;
	
	Если Параметры.Свойство("ВариантОтчета") Тогда
		ВариантОтчета = Параметры.ВариантОтчета;
	Иначе
		Отказ = Истина;
	КонецЕсли;

КонецПроцедуры

#КонецОбласти
