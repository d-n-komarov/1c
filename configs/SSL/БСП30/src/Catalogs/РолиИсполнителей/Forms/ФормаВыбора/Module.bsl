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
	
	УстановитьУсловноеОформление();
	
	ТолькоПростыеРоли = Ложь;
	
	Если Параметры.Свойство("ТолькоПростыеРоли", ТолькоПростыеРоли) И ТолькоПростыеРоли = Истина Тогда
		ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
			Список, "ВнешняяРоль", Истина, , , Истина);
	КонецЕсли;
	
	ЭтоВнешнийПользователь = Пользователи.ЭтоСеансВнешнегоПользователя();
	
	Если ЭтоВнешнийПользователь Тогда
		
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы.КоманднаяПанель.ПодчиненныеЭлементы, "ФормаИзменить",
			"Видимость", Ложь);
		СтрокаОтбораВТекстеЗапроса = ОпределитьОтборДляВнешнегоПользователя();
		
	Иначе
		
		СтрокаОтбораВТекстеЗапроса = " ГДЕ РолиИсполнителейНазначениеПереопределяемый.ТипПользователей = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)";
		
	КонецЕсли;
	
	СвойстваСписка = ОбщегоНазначения.СтруктураСвойствДинамическогоСписка();
	СвойстваСписка.ОсновнаяТаблица              = "Справочник.РолиИсполнителей";
	СвойстваСписка.ДинамическоеСчитываниеДанных = Истина;
	СвойстваСписка.ТекстЗапроса                 = Список.ТекстЗапроса + СтрокаОтбораВТекстеЗапроса;
	ОбщегоНазначения.УстановитьСвойстваДинамическогоСписка(Элементы.Список, СвойстваСписка);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура СписокПередНачаломИзменения(Элемент, Отказ)
	
	Если ЭтоВнешнийПользователь Тогда
		Отказ = Истина;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция ОпределитьОтборДляВнешнегоПользователя()
	
	ТекущийВнешнийПользователь =  ВнешниеПользователи.ТекущийВнешнийПользователь();
	
	СтрокаОтбораВТекстеЗапроса = СтрЗаменить(" ГДЕ РолиИсполнителейНазначениеПереопределяемый.ТипПользователей = ЗНАЧЕНИЕ(Справочник.%Имя%.ПустаяСсылка)",
		"%Имя%", ТекущийВнешнийПользователь.ОбъектАвторизации.Метаданные().Имя);
	
	Возврат СтрокаОтбораВТекстеЗапроса;
	
КонецФункции

&НаСервере
Процедура УстановитьУсловноеОформление()
	
	Список.УсловноеОформление.Элементы.Очистить();
	Элемент = Список.УсловноеОформление.Элементы.Добавить();
	
	ГруппаЭлементовОтбора = Элемент.Отбор.Элементы.Добавить(Тип("ГруппаЭлементовОтбораКомпоновкиДанных"));
	ГруппаЭлементовОтбора .ТипГруппы = ТипГруппыЭлементовОтбораКомпоновкиДанных.ГруппаИ;
	
	ОтборЭлемента = ГруппаЭлементовОтбора.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ЕстьИсполнители");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Ложь;
	
	ОтборЭлемента = ГруппаЭлементовОтбора.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ВнешняяРоль");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Ложь;
	
	Элемент.Оформление.УстановитьЗначениеПараметра("ЦветТекста", ЦветаСтиля.РольБезИсполнителей);
	
КонецПроцедуры

#КонецОбласти