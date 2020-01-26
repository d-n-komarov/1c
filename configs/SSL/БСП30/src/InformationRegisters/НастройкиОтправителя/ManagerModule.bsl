///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

// Определяет конечные точки, для которых в текущей информационной системе 
// назначен заданный канал сообщений.
//
// Параметры:
//  КаналСообщений - Строка. Идентификатор адресного канала сообщений.
//
// Возвращаемое значение:
//  Тип: Массив. Массив элементов конечных точек.
//  Массив содержит элементы типа ПланОбменаСсылка.ОбменСообщениями.
//
Функция ПодписчикиКаналаСообщений(Знач КаналСообщений) Экспорт
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	НастройкиОтправителя.Получатель КАК Получатель
	|ИЗ
	|	РегистрСведений.НастройкиОтправителя КАК НастройкиОтправителя
	|ГДЕ
	|	НастройкиОтправителя.КаналСообщений = &КаналСообщений";
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("КаналСообщений", КаналСообщений);
	Запрос.Текст = ТекстЗапроса;
	
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Получатель");
КонецФункции

#КонецОбласти

#КонецЕсли