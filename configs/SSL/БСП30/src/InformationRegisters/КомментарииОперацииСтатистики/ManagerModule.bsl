///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

Процедура СоздатьНовуюЗапись(ОперацияСтатистики, КомментарийСтатистики) Экспорт
	НачатьТранзакцию();
	Попытка
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.КомментарииОперацииСтатистики");
		ЭлементБлокировки.УстановитьЗначение("ИдентификаторОперации", ОперацияСтатистики);
		ЭлементБлокировки.УстановитьЗначение("ИдентификаторКомментария", КомментарийСтатистики);
		Блокировка.Заблокировать();
		
		Если НЕ ЕстьЗапись(ОперацияСтатистики, КомментарийСтатистики) Тогда
			НаборЗаписей = СоздатьНаборЗаписей();
			НовЗапись = НаборЗаписей.Добавить();
			НовЗапись.ИдентификаторОперации = ОперацияСтатистики; 
			НовЗапись.ИдентификаторКомментария = КомментарийСтатистики;
			
			НаборЗаписей.ОбменДанными.Загрузка = Истина;
			НаборЗаписей.Записать(Ложь);
		КонецЕсли;
				
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
КонецПроцедуры

Функция ЕстьЗапись(ОперацияСтатистики, КомментарийСтатистики)
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	КОЛИЧЕСТВО(*) КАК КоличествоЗаписей
		|ИЗ
		|	РегистрСведений.КомментарииОперацииСтатистики КАК КомментарииОперацииСтатистики
		|ГДЕ
		|	КомментарииОперацииСтатистики.ИдентификаторОперации = &ИдентификаторОперации
		|	И КомментарииОперацииСтатистики.ИдентификаторКомментария = &ИдентификаторКомментария
		|";
	
	Запрос.УстановитьПараметр("ИдентификаторКомментария", КомментарийСтатистики);
	Запрос.УстановитьПараметр("ИдентификаторОперации", ОперацияСтатистики);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	ВыборкаДетальныеЗаписи.Следующий();
	
	Если ВыборкаДетальныеЗаписи.КоличествоЗаписей = 0 Тогда
		Возврат Ложь;
	Иначе
		Возврат Истина;
	КонецЕсли;
КонецФункции

#КонецОбласти

#КонецЕсли