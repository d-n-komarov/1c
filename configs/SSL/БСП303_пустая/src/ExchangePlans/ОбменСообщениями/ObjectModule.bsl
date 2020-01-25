///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ЭтоНовый() Тогда
		
		Если ПометкаУдаления <> ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Ссылка, "ПометкаУдаления") Тогда
			
			УстановитьПривилегированныйРежим(Истина);
			
			УстановитьПометкуУдаленияСвязаннымОбъектам(Ссылка, ПометкаУдаления);
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПередУдалением(Отказ)
	
	// Проверка значения свойства ОбменДанными.Загрузка отсутствует по причине того, что в расположенным ниже коде,
	// реализована логика, которая должна выполняться в том числе при установке этого свойства равным Истина
	// (на стороне кода, который выполняет попытку записи в данный план обмена).
	
	УстановитьПривилегированныйРежим(Истина);
	ОбщегоНазначения.УдалитьДанныеИзБезопасногоХранилища(Ссылка);
	УстановитьПривилегированныйРежим(Ложь);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Устанавливает или снимает пометку удаления всем связанным объектам.
//
// Параметры:
//  Владелец        - ПланОбменаСсылка, СправочникСсылка, ДокументСсылка - ссылка на объект, который является
//                    "владельцем" по отношению к помечаемым на удаление объектам.
//
//  ПометкаУдаления - Булево - признак установки/снятия пометки на удаление у всех "подчиненных" объектов.
//
Процедура УстановитьПометкуУдаленияСвязаннымОбъектам(Знач Владелец, Знач ПометкаУдаления)
	
	НачатьТранзакцию();
	Попытка
		
		СписокСсылок = Новый Массив;
		СписокСсылок.Добавить(Владелец);
		Ссылки = НайтиПоСсылкам(СписокСсылок);
		
		Для Каждого ТекущаяСсылка Из Ссылки Цикл
			
			Если ОбщегоНазначения.ЗначениеСсылочногоТипа(ТекущаяСсылка[1]) Тогда
				ТекущаяСсылка[1].ПолучитьОбъект().УстановитьПометкуУдаления(ПометкаУдаления);
			КонецЕсли;
			
		КонецЦикла;
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли