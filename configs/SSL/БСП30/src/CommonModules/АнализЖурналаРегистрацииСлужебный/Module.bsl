///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий подсистем конфигурации.

// См. ОбщегоНазначенияПереопределяемый.ПриДобавленииПереименованийОбъектовМетаданных.
Процедура ПриДобавленииПереименованийОбъектовМетаданных(Итог) Экспорт
	
	Библиотека = "СтандартныеПодсистемы";
	
	ОбщегоНазначения.ДобавитьПереименование(Итог,
		"2.1.0.1",
		"Подсистема.СтандартныеПодсистемы.Подсистема.КонтрольЖурналаРегистрации",
		"Подсистема.СтандартныеПодсистемы.Подсистема.АнализЖурналаРегистрации",
		Библиотека);
	
КонецПроцедуры

// См. ВариантыОтчетовПереопределяемый.НастроитьВариантыОтчетов.
Процедура ПриНастройкеВариантовОтчетов(Настройки) Экспорт
	МодульВариантыОтчетов = ОбщегоНазначения.ОбщийМодуль("ВариантыОтчетов");
	МодульВариантыОтчетов.НастроитьОтчетВМодулеМенеджера(Настройки, Метаданные.Отчеты.АнализЖурналаРегистрации);
КонецПроцедуры

#КонецОбласти

