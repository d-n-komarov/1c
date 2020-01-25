///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

// Выполняет отправку и получение сообщений системы.
//
// Параметры:
//  Отказ - Булево. Флаг отказа. Поднимается в случае возникновения ошибок в процессе выполнения операции.
//
Процедура ОтправитьИПолучитьСообщения(Отказ) Экспорт
	
	ОбменДаннымиСервер.ПроверитьВозможностьВыполненияОбменов();
	
	ОбменСообщениямиВнутренний.ОтправитьИПолучитьСообщения(Отказ);
	
КонецПроцедуры

#КонецОбласти
