///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Предлагает пользователю создать резервную копию.
//
Процедура ПредложитьПользователюСоздатьРезервнуюКопию() Экспорт
	
	Если СтандартныеПодсистемыКлиент.ПараметрыРаботыКлиента().РезервноеКопированиеОбластейДанных Тогда
		
		ИмяФормы = "ОбщаяФорма.СозданиеРезервнойКопии";
		
	Иначе
		
		ИмяФормы = "ОбщаяФорма.ВыгрузкаДанных";
		
	КонецЕсли;
	
	ОткрытьФорму(ИмяФормы);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий подсистем конфигурации.

// См. ИнтеграцияПодсистемБСПКлиент.ПриПроверкеВозможностиРезервногоКопированияВПользовательскомРежиме.
Процедура ПриПроверкеВозможностиРезервногоКопированияВПользовательскомРежиме(Результат) Экспорт
	
	Если СтандартныеПодсистемыКлиент.ПараметрыРаботыКлиента().РазделениеВключено Тогда
		
		Результат = Истина;
		
	КонецЕсли;
	
КонецПроцедуры

// См. ИнтеграцияПодсистемБСПКлиент.ПриПредложенииПользователюСоздатьРезервнуюКопию.
Процедура ПриПредложенииПользователюСоздатьРезервнуюКопию() Экспорт
	
	Если СтандартныеПодсистемыКлиент.ПараметрыРаботыКлиента().РазделениеВключено Тогда
		
		ПредложитьПользователюСоздатьРезервнуюКопию();
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти