///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

Функция ПолучитьПараметрыФормыНастроек(Знач ОбластьДанных) Экспорт
	
	Параметры = Реализация().ПолучитьПараметрыФормыНастроек(ОбластьДанных);
	Параметры.Вставить("ОбластьДанных", ОбластьДанных);
	
	Возврат Параметры;
	
КонецФункции

Функция ПолучитьНастройкиОбласти(Знач ОбластьДанных) Экспорт
	
	Возврат Реализация().ПолучитьНастройкиОбласти(ОбластьДанных);
	
КонецФункции

Процедура УстановитьНастройкиОбласти(Знач ОбластьДанных, Знач НовыеНастройки, Знач ИсходныеНастройки) Экспорт
	
	Реализация().УстановитьНастройкиОбласти(ОбластьДанных, НовыеНастройки, ИсходныеНастройки);
	
КонецПроцедуры

Функция ПолучитьСтандартныеНастройки() Экспорт
	
	Возврат Реализация().ПолучитьСтандартныеНастройки();
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// ВСПОМОГАТЕЛЬНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

Функция Реализация()
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.РезервноеКопированиеОбластейДанныхМС") Тогда
		Возврат ОбщегоНазначения.ОбщийМодуль("РезервноеКопированиеОбластейДанныхДанныеФормИнтерфейс");
	Иначе
		Возврат ОбщегоНазначения.ОбщийМодуль("РезервноеКопированиеОбластейДанныхДанныеФормРеализацияWebСервис");
	КонецЕсли;
	
КонецФункции

#КонецОбласти
