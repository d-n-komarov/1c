///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

// Формирует и сохраняет в ИБ план обновления областей данных.
//
// Параметры:
//  ИдентификаторБиблиотеки  - Строка - имя конфигурации или идентификатор библиотеки,
//  ВсеОбработчики    - Соответствие - список всех обработчиков обновления,
//  ОбязательныеРазделенныеОбработчики    - Соответствие - список обязательных
//    обработчиков обновления с ОбщиеДанные = Ложь,
//  ИсходнаяВерсияИБ - Строка - исходная версия информационной базы,
//  ВерсияМетаданныхИБ - Строка - версия конфигурации (из метаданных).
//
Процедура СформироватьПланОбновленияОбластиДанных(ИдентификаторБиблиотеки, ВсеОбработчики, 
	ОбязательныеРазделенныеОбработчики, ИсходнаяВерсияИБ, ВерсияМетаданныхИБ) Экспорт
	
	Если РаботаВМоделиСервиса.РазделениеВключено()
		И Не РаботаВМоделиСервиса.ДоступноИспользованиеРазделенныхДанных() Тогда
		
		ОбработчикиОбновления = ВсеОбработчики.СкопироватьКолонки();
		Для Каждого СтрокаОбработчика Из ВсеОбработчики Цикл
			// При формировании плана обновлении области, по умолчанию не добавляем обязательные (*) обработчики.
			Если СтрокаОбработчика.Версия = "*" Тогда
				Продолжить;
			КонецЕсли;
			ЗаполнитьЗначенияСвойств(ОбработчикиОбновления.Добавить(), СтрокаОбработчика);
		КонецЦикла;
		
		Для Каждого ОбязательныйОбработчик Из ОбязательныеРазделенныеОбработчики Цикл
			СтрокаОбработчика = ОбработчикиОбновления.Добавить();
			ЗаполнитьЗначенияСвойств(СтрокаОбработчика, ОбязательныйОбработчик);
			СтрокаОбработчика.Версия = "*";
		КонецЦикла;
		
		ПараметрыОтбора = ОбновлениеИнформационнойБазыСлужебный.ПараметрыОтбораОбработчиков();
		ПараметрыОтбора.ПолучатьРазделенные = Истина;
		ПланОбновленияОбластиДанных = ОбновлениеИнформационнойБазыСлужебный.ОбработчикиОбновленияВИнтервале(
			ОбработчикиОбновления, ИсходнаяВерсияИБ, ВерсияМетаданныхИБ, ПараметрыОтбора);
			
		ОписаниеПлана = Новый Структура;
		ОписаниеПлана.Вставить("ВерсияС", ИсходнаяВерсияИБ);
		ОписаниеПлана.Вставить("ВерсияНа", ВерсияМетаданныхИБ);
		ОписаниеПлана.Вставить("План", ПланОбновленияОбластиДанных);
		
		МенеджерЗаписи = РегистрыСведений.ВерсииПодсистем.СоздатьМенеджерЗаписи();
		МенеджерЗаписи.ИмяПодсистемы = ИдентификаторБиблиотеки;
		
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.ВерсииПодсистем");
		ЭлементБлокировки.УстановитьЗначение("ИмяПодсистемы", ИдентификаторБиблиотеки);
		
		НачатьТранзакцию();
		Попытка
			Блокировка.Заблокировать();
			
			МенеджерЗаписи.Прочитать();
			МенеджерЗаписи.ПланОбновления = Новый ХранилищеЗначения(ОписаниеПлана);
			МенеджерЗаписи.Записать();
			
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			ВызватьИсключение;
		КонецПопытки;
		
		ПланОбновленияПустой = ПланОбновленияОбластиДанных.Строки.Количество() = 0;
		
		Если ИдентификаторБиблиотеки = Метаданные.Имя Тогда
			// Версию конфигурации можно устанавливать только если ни какие библиотеки не требует обновления
			// иначе механизм обновления в областях не будет запущен и библиотеки останутся не обновленными.
			ПланОбновленияПустой = Ложь;
			
			// Проверка всех планов на пустоту.
			Библиотеки = Новый ТаблицаЗначений;
			Библиотеки.Колонки.Добавить("Имя", Метаданные.РегистрыСведений.ВерсииПодсистем.Измерения.ИмяПодсистемы.Тип);
			Библиотеки.Колонки.Добавить("Версия", Метаданные.РегистрыСведений.ВерсииПодсистем.Ресурсы.Версия.Тип);
			
			ОписанияПодсистем  = СтандартныеПодсистемыПовтИсп.ОписанияПодсистем();
			Для каждого ИмяПодсистемы Из ОписанияПодсистем.Порядок Цикл
				ОписаниеПодсистемы = ОписанияПодсистем.ПоИменам.Получить(ИмяПодсистемы);
				Если НЕ ЗначениеЗаполнено(ОписаниеПодсистемы.ОсновнойСерверныйМодуль) Тогда
					// У библиотеки нет модуля - нет и обработчиков обновления.
					Продолжить;
				КонецЕсли;
				
				СтрокаБиблиотеки = Библиотеки.Добавить();
				СтрокаБиблиотеки.Имя = ОписаниеПодсистемы.Имя;
				СтрокаБиблиотеки.Версия = ОписаниеПодсистемы.Версия;
			КонецЦикла;
			
			Запрос = Новый Запрос;
			Запрос.УстановитьПараметр("Библиотеки", Библиотеки);
			Запрос.Текст =
				"ВЫБРАТЬ
				|	Библиотеки.Имя КАК Имя,
				|	Библиотеки.Версия КАК Версия
				|ПОМЕСТИТЬ Библиотеки
				|ИЗ
				|	&Библиотеки КАК Библиотеки
				|;
				|
				|////////////////////////////////////////////////////////////////////////////////
				|ВЫБРАТЬ
				|	Библиотеки.Имя КАК Имя,
				|	Библиотеки.Версия КАК Версия,
				|	ВерсииПодсистем.ПланОбновления КАК ПланОбновления,
				|	ВЫБОР
				|		КОГДА ВерсииПодсистем.Версия = Библиотеки.Версия
				|			ТОГДА ИСТИНА
				|		ИНАЧЕ ЛОЖЬ
				|	КОНЕЦ КАК Обновлена
				|ИЗ
				|	Библиотеки КАК Библиотеки
				|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ВерсииПодсистем КАК ВерсииПодсистем
				|		ПО Библиотеки.Имя = ВерсииПодсистем.ИмяПодсистемы";
				
			НачатьТранзакцию();
			Попытка
				Блокировка = Новый БлокировкаДанных;
				ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.ВерсииПодсистем");
				ЭлементБлокировки.Режим = РежимБлокировкиДанных.Разделяемый;
				Блокировка.Заблокировать();
				
				Результат = Запрос.Выполнить();
				
				ЗафиксироватьТранзакцию();
			Исключение
				ОтменитьТранзакцию();
				ВызватьИсключение;
			КонецПопытки;
			
			Выборка = Результат.Выбрать();
			Пока Выборка.Следующий() Цикл
				
				Если НЕ Выборка.Обновлена Тогда
					ПланОбновленияПустой = Ложь;
					
					ШаблонКомментария = НСтр("ru = 'Обновление версии конфигурации было выполнено до обновления версии библиотеки %1'");
					ТекстКомментария = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонКомментария, Выборка.Имя);
					ЗаписьЖурналаРегистрации(
						ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(),
						УровеньЖурналаРегистрации.Ошибка,
						,
						,
						ТекстКомментария);
					
					Прервать;
				КонецЕсли;
				
				Если Выборка.ПланОбновления = Неопределено Тогда
					ОписаниеПланаОбновленияБиблиотеки = Неопределено;
				Иначе
					ОписаниеПланаОбновленияБиблиотеки = Выборка.ПланОбновления.Получить();
				КонецЕсли;
				
				Если ОписаниеПланаОбновленияБиблиотеки = Неопределено Тогда
					ПланОбновленияПустой = Ложь;
					
					ШаблонКомментария = НСтр("ru = 'Не найден план обновления библиотеки %1'");
					ТекстКомментария = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонКомментария, Выборка.Имя);
					ЗаписьЖурналаРегистрации(
						ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(),
						УровеньЖурналаРегистрации.Ошибка,
						,
						,
						ТекстКомментария);
					
					Прервать;
				КонецЕсли;
				
				Если ОписаниеПланаОбновленияБиблиотеки.ВерсияНа <> Выборка.Версия Тогда
					ПланОбновленияПустой = Ложь;
					
					ШаблонКомментария = НСтр("ru = 'Обнаружен некорректный план обновления библиотеки %1
						|Требуется план обновления на версию %2, найден план для обновления на версию %3'");
					ТекстКомментария = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонКомментария, Выборка.Имя, Строка(ОписаниеПланаОбновленияБиблиотеки.ВерсияНа), Строка(Выборка.Версия));
					ЗаписьЖурналаРегистрации(
						ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(),
						УровеньЖурналаРегистрации.Ошибка,
						,
						,
						ТекстКомментария);
					
					Прервать;
				КонецЕсли;
				
				Если ОписаниеПланаОбновленияБиблиотеки.План.Строки.Количество() > 0 Тогда
					ПланОбновленияПустой = Ложь;
					Прервать;
				КонецЕсли;
				
			КонецЦикла;
		КонецЕсли;
		
		Если ПланОбновленияПустой Тогда
			
			// План обновления не содержит разделенных оперативных или монопольных обработчиков.
			// Выполняется проверка наличия разделенных отложенных обработчиков.
			ПараметрыОтбораОтложенных = ОбновлениеИнформационнойБазыСлужебный.ПараметрыОтбораОбработчиков();
			ПараметрыОтбораОтложенных.ПолучатьРазделенные = Истина;
			ПараметрыОтбораОтложенных.РежимОбновления = "Отложенно";
			
			ОтложенныеОбработчики = ОбновлениеИнформационнойБазыСлужебный.ОбработчикиОбновленияВИнтервале(ОбработчикиОбновления, ИсходнаяВерсияИБ, ВерсияМетаданныхИБ, ПараметрыОтбораОтложенных);
			
			// Нет разделенных отложенных обработчиков, установить новую версию библиотеки.
			Если ОтложенныеОбработчики.Строки.Количество() = 0 Тогда
			
				УстановитьВерсиюВсехОбластейДанных(ИдентификаторБиблиотеки, ИсходнаяВерсияИБ, ВерсияМетаданныхИБ);
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

// Блокирует запись в регистре сведений ВерсииПодсистемОбластейДанных, которая соответствует текущей области данных,
// и возвращает ключ этой записи.
//
// Возвращаемое значение: 
//   РегистрСведенийКлючЗаписи.
//
Функция ЗаблокироватьВерсииОбластиДанных() Экспорт
	
	КлючЗаписи = Неопределено;
	Если РаботаВМоделиСервиса.РазделениеВключено() Тогда
		
		Если РаботаВМоделиСервиса.ДоступноИспользованиеРазделенныхДанных() Тогда
			УстановитьПривилегированныйРежим(Истина);
		КонецЕсли;
		
		КлючЗаписи = КлючЗаписиВерсийПодсистем();
		
	КонецЕсли;
	
	Если КлючЗаписи <> Неопределено Тогда
		Попытка
			ЗаблокироватьДанныеДляРедактирования(КлючЗаписи);
		Исключение
			ЗаписьЖурналаРегистрации(ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации() + "." 
				+ НСтр("ru = 'Обновление области данных'", ОбщегоНазначения.КодОсновногоЯзыка()),
				УровеньЖурналаРегистрации.Ошибка,,,
				ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			ВызватьИсключение(НСтр("ru = 'Ошибка обновления области данных. Запись версий области данных заблокирована.'"));
		КонецПопытки;
	КонецЕсли;
	Возврат КлючЗаписи;
	
КонецФункции

// Разблокирует запись в регистре сведений ВерсииПодсистемОбластейДанных.
//
// Параметры: 
//   КлючЗаписи - РегистрСведенийКлючЗаписи.
//
Процедура РазблокироватьВерсииОбластиДанных(КлючЗаписи) Экспорт
	
	Если КлючЗаписи <> Неопределено Тогда
		РазблокироватьДанныеДляРедактирования(КлючЗаписи);
	КонецЕсли;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий подсистем конфигурации.

// Устанавливает в очереди заданий флаг использования того задания, которое
// соответствует регламентному заданию для выполнения отложенного обновления.
//
// Параметры:
//  Использование - Булево - новое значения флага использования.
//
Процедура ПриВключенииОтложенногоОбновления(Знач Использование) Экспорт
	
	Шаблон = ОчередьЗаданий.ШаблонПоИмени("ОтложенноеОбновлениеИБ");
	
	ОтборЗадания = Новый Структура;
	ОтборЗадания.Вставить("Шаблон", Шаблон);
	Задания = ОчередьЗаданий.ПолучитьЗадания(ОтборЗадания);
	
	ПараметрыЗадания = Новый Структура("Использование", Использование);
	ОчередьЗаданий.ИзменитьЗадание(Задания[0].Идентификатор, ПараметрыЗадания);
	
КонецПроцедуры

// См. ОбновлениеИнформационнойБазыБСП.ПередОбновлениемИнформационнойБазы.
Процедура ПередОбновлениемИнформационнойБазы() Экспорт
	
	Если РаботаВМоделиСервиса.РазделениеВключено()
	   И РаботаВМоделиСервиса.ДоступноИспользованиеРазделенныхДанных() Тогда
		
		ВерсияОбщихДанных = ОбновлениеИнформационнойБазыСлужебный.ВерсияИБ(Метаданные.Имя, Истина);
		Если ОбновлениеИнформационнойБазыСлужебный.НеобходимоВыполнитьОбновление(Метаданные.Версия, ВерсияОбщихДанных) Тогда
			Сообщение = НСтр("ru = 'Не выполнена общая часть обновления информационной базы.
				|Обратитесь к администратору.'");
			ЗаписьЖурналаРегистрации(ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(), УровеньЖурналаРегистрации.Ошибка,,, Сообщение);
			ВызватьИсключение Сообщение;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры	

// Только для внутреннего использования.
Процедура ПриОпределенииВерсииИБ(Знач ИдентификаторБиблиотеки, Знач ПолучитьВерсиюОбщихДанных, СтандартнаяОбработка, ВерсияИБ) Экспорт
	
	Если РаботаВМоделиСервиса.ИспользованиеРазделителяСеанса() И Не ПолучитьВерсиюОбщихДанных Тогда
		
		СтандартнаяОбработка = Ложь;
		
		ТекстЗапроса = 
		"ВЫБРАТЬ
		|	ВерсииПодсистемОбластейДанных.Версия
		|ИЗ
		|	РегистрСведений.ВерсииПодсистемОбластейДанных КАК ВерсииПодсистемОбластейДанных
		|ГДЕ
		|	ВерсииПодсистемОбластейДанных.ИмяПодсистемы = &ИмяПодсистемы
		|	И ВерсииПодсистемОбластейДанных.ОбластьДанныхВспомогательныеДанные = &ОбластьДанныхВспомогательныеДанные";
		Запрос = Новый Запрос(ТекстЗапроса);
		Запрос.УстановитьПараметр("ИмяПодсистемы", ИдентификаторБиблиотеки);
		Запрос.УстановитьПараметр("ОбластьДанныхВспомогательныеДанные", РаботаВМоделиСервиса.ЗначениеРазделителяСеанса());
		ТаблицаЗначений = Запрос.Выполнить().Выгрузить();
		ВерсияИБ = "";
		Если ТаблицаЗначений.Количество() > 0 Тогда
			ВерсияИБ = СокрЛП(ТаблицаЗначений[0].Версия);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

// Только для внутреннего использования.
Процедура ПриОпределенииПервогоВходаВОбластьДанных(СтандартнаяОбработка, Результат) Экспорт
	
	Если РаботаВМоделиСервиса.ИспользованиеРазделителяСеанса() Тогда
		
		СтандартнаяОбработка = Ложь;
		
		ТекстЗапроса = 
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	1
		|ИЗ
		|	РегистрСведений.ВерсииПодсистемОбластейДанных КАК ВерсииПодсистемОбластейДанных
		|ГДЕ
		|	ВерсииПодсистемОбластейДанных.ОбластьДанныхВспомогательныеДанные = &ОбластьДанныхВспомогательныеДанные";
		Запрос = Новый Запрос(ТекстЗапроса);
		Запрос.УстановитьПараметр("ОбластьДанныхВспомогательныеДанные", РаботаВМоделиСервиса.ЗначениеРазделителяСеанса());
		Результат = Запрос.Выполнить().Пустой();
		
	КонецЕсли;
	
КонецПроцедуры

// Только для внутреннего использования.
Процедура ПриУстановкеВерсииИБ(Знач ИдентификаторБиблиотеки, Знач НомерВерсии, СтандартнаяОбработка) Экспорт
	
	Если РаботаВМоделиСервиса.ИспользованиеРазделителяСеанса() Тогда
		
		СтандартнаяОбработка = Ложь;
		
		ОбластьДанных = РаботаВМоделиСервиса.ЗначениеРазделителяСеанса();
		
		МенеджерЗаписи = РегистрыСведений.ВерсииПодсистемОбластейДанных.СоздатьМенеджерЗаписи();
		МенеджерЗаписи.ОбластьДанныхВспомогательныеДанные = ОбластьДанных;
		МенеджерЗаписи.ИмяПодсистемы = ИдентификаторБиблиотеки;
		МенеджерЗаписи.Версия = НомерВерсии;
		МенеджерЗаписи.Записать();
		
	КонецЕсли;
	
КонецПроцедуры

// Только для внутреннего использования.
Процедура ПриПроверкеРегистрацииОтложенныхОбработчиковОбновления(РегистрацияВыполнена, СтандартнаяОбработка) Экспорт
	
	Если РаботаВМоделиСервиса.ИспользованиеРазделителяСеанса() Тогда
		СтандартнаяОбработка = Ложь;
		Запрос = Новый Запрос;
		Запрос.Текст =
			"ВЫБРАТЬ
			|	ВерсииПодсистемОбластейДанных.ИмяПодсистемы
			|ИЗ
			|	РегистрСведений.ВерсииПодсистемОбластейДанных КАК ВерсииПодсистемОбластейДанных
			|ГДЕ
			|	НЕ ВерсииПодсистемОбластейДанных.ВыполненаРегистрацияОтложенныхОбработчиков
			|	И ВерсииПодсистемОбластейДанных.ОбластьДанныхВспомогательныеДанные = &ОбластьДанныхВспомогательныеДанные";
			
		Запрос.УстановитьПараметр("ОбластьДанныхВспомогательныеДанные", РаботаВМоделиСервиса.ЗначениеРазделителяСеанса());
		Результат = Запрос.Выполнить().Выгрузить();
		РегистрацияВыполнена = (Результат.Количество() = 0);
	КонецЕсли;
	
КонецПроцедуры

// Только для внутреннего использования.
Процедура ПриОтметкеРегистрацииОтложенныхОбработчиковОбновления(ИмяПодсистемы, Значение, СтандартнаяОбработка) Экспорт
	
	Если РаботаВМоделиСервиса.ИспользованиеРазделителяСеанса() Тогда
		СтандартнаяОбработка = Ложь;
		
		НаборЗаписей = РегистрыСведений.ВерсииПодсистемОбластейДанных.СоздатьНаборЗаписей();
		Если ИмяПодсистемы <> Неопределено Тогда
			НаборЗаписей.Отбор.ИмяПодсистемы.Установить(ИмяПодсистемы);
		КонецЕсли;
		НаборЗаписей.Прочитать();
		
		Если НаборЗаписей.Количество() = 0 Тогда
			Возврат;
		КонецЕсли;
		
		Для Каждого ЗаписьРегистра Из НаборЗаписей Цикл
			ЗаписьРегистра.ВыполненаРегистрацияОтложенныхОбработчиков = Значение;
		КонецЦикла;
		НаборЗаписей.Записать();
	КонецЕсли;
	
КонецПроцедуры

// Только для внутреннего использования.
Процедура ПриОтправкеВерсийПодсистем(ЭлементДанных, ОтправкаЭлемента, Знач СозданиеНачальногоОбраза, СтандартнаяОбработка) Экспорт
	
	Если Не РаботаВМоделиСервиса.ИспользованиеРазделителяСеанса() Тогда
		Возврат;
	КонецЕсли;
	СтандартнаяОбработка = Ложь;
	
	Если ОтправкаЭлемента = ОтправкаЭлементаДанных.Удалить
		ИЛИ ОтправкаЭлемента = ОтправкаЭлементаДанных.Игнорировать Тогда
		
		// Стандартную обработку не переопределяем.
		
	ИначеЕсли ТипЗнч(ЭлементДанных) = Тип("РегистрСведенийНаборЗаписей.ВерсииПодсистем") Тогда
		
		Если СозданиеНачальногоОбраза Тогда
			
			Если РаботаВМоделиСервиса.РазделениеВключено() Тогда
				
				Если РаботаВМоделиСервиса.ДоступноИспользованиеРазделенныхДанных() Тогда
					
					Для Каждого СтрокаНабора Из ЭлементДанных Цикл
						
						ТекстЗапроса =
						"ВЫБРАТЬ
						|	ВерсииПодсистемОбластейДанных.Версия КАК Версия
						|ИЗ
						|	РегистрСведений.ВерсииПодсистемОбластейДанных КАК ВерсииПодсистемОбластейДанных
						|ГДЕ
						|	ВерсииПодсистемОбластейДанных.ИмяПодсистемы = &ИмяПодсистемы";
						
						Запрос = Новый Запрос;
						Запрос.УстановитьПараметр("ИмяПодсистемы", СтрокаНабора.ИмяПодсистемы);
						Запрос.Текст = ТекстЗапроса;
						
						Выборка = Запрос.Выполнить().Выбрать();
						
						Если Выборка.Следующий() Тогда
							
							СтрокаНабора.Версия = Выборка.Версия;
							
						Иначе
							
							СтрокаНабора.Версия = "";
							
						КонецЕсли;
						
					КонецЦикла;
					
				КонецЕсли;
				
			Иначе
				
				// При создании начального образа с отключенным разделением
				// выгрузку регистра выполняем без дополнительной обработки.
				
			КонецЕсли;
			
		Иначе
			
			// Выгрузку регистра выполняем только при создании начального образа.
			ОтправкаЭлемента = ОтправкаЭлементаДанных.Игнорировать;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

// См. ОчередьЗаданийПереопределяемый.ПриОпределенииПсевдонимовОбработчиков.
Процедура ПриОпределенииПсевдонимовОбработчиков(СоответствиеИменПсевдонимам) Экспорт
	
	СоответствиеИменПсевдонимам.Вставить("ОбновлениеИнформационнойБазыСлужебныйВМоделиСервиса.ВыполнитьОбновлениеТекущейОбластиДанных");
	
КонецПроцедуры

// См. ВыгрузкаЗагрузкаДанныхПереопределяемый.ПриЗаполненииТиповИсключаемыхИзВыгрузкиЗагрузки.
Процедура ПриЗаполненииТиповИсключаемыхИзВыгрузкиЗагрузки(Типы) Экспорт
	
	Типы.Добавить(Метаданные.РегистрыСведений.ВерсииПодсистемОбластейДанных);
	
КонецПроцедуры

// См. ОчередьЗаданийПереопределяемый.ПриОпределенииИспользованияРегламентныхЗаданий.
Процедура ПриОпределенииИспользованияРегламентныхЗаданий(ТаблицаИспользования) Экспорт
	
	НоваяСтрока = ТаблицаИспользования.Добавить();
	НоваяСтрока.РегламентноеЗадание = "ОбновлениеОбластейДанных";
	НоваяСтрока.Использование       = Истина;
	
КонецПроцедуры

// См. ОбновлениеИнформационнойБазыБСП.ПослеОбновленияИнформационнойБазы.
Процедура ПослеОбновленияИнформационнойБазы(Знач ПредыдущаяВерсия, Знач ТекущаяВерсия,
		Знач ВыполненныеОбработчики, ВыводитьОписаниеОбновлений, МонопольныйРежим) Экспорт
	
	Если РаботаВМоделиСервиса.ДоступноИспользованиеРазделенныхДанных() Тогда
		
		ПараметрыБлокировки = СоединенияИБ.ПолучитьБлокировкуСеансовОбластиДанных();
		Если НЕ ПараметрыБлокировки.Установлена Тогда
			Возврат;
		КонецЕсли;
		ПараметрыБлокировки.Установлена = Ложь;
		СоединенияИБ.УстановитьБлокировкуСеансовОбластиДанных(ПараметрыБлокировки);
		
	Иначе
		
		СнятьМонопольныйРежим = Ложь;
		Если Не МонопольныйРежим() Тогда
			
			Попытка
				УстановитьМонопольныйРежим(Истина);
				СнятьМонопольныйРежим = Истина;
			Исключение
				// Обработка исключения не требуется.
				// Ожидаемое исключение - ошибка установки монопольного режима из-за
				// наличия других сеансов (например, при динамическом обновлении конфигурации).
				// В этом случае планирование обновления областей будет выполняться с учетом
				// возможной конкуренции при доступе к таблицам объектов метаданных, разделенных
				// в режиме "Независимо и совместно" (что будет менее эффективно, нежели в
				// выполнение в монопольном режиме).
				СтрокаСообщения = НСтр("ru = 'Не удалось установить монопольный режим. Описание ошибки: %1'", ОбщегоНазначения.КодОсновногоЯзыка());
				СтрокаСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(СтрокаСообщения, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
				
				ЗаписьЖурналаРегистрации(ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(), 
					УровеньЖурналаРегистрации.Предупреждение, , , СтрокаСообщения);
			КонецПопытки;
			
		КонецЕсли;
		
		ЗапланироватьОбновлениеОбластейДанных(Истина);
		
		Если СнятьМонопольныйРежим Тогда
			УстановитьМонопольныйРежим(Ложь);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

// См. ОбновлениеИнформационнойБазыБСП.ПриДобавленииОбработчиковОбновления.
Процедура ПриДобавленииОбработчиковОбновления(Обработчики) Экспорт
	
	Обработчик = Обработчики.Добавить();
	Обработчик.Версия = "2.1.3.19";
	Обработчик.Процедура = "ОбновлениеИнформационнойБазыСлужебныйВМоделиСервиса.ПеренестиВерсииПодсистемВоВспомогательныеДанные";
	Обработчик.ОбщиеДанные = Истина;
	
	Обработчик                     = Обработчики.Добавить();
	Обработчик.Версия              = "2.3.1.48";
	Обработчик.МонопольныйРежим    = Ложь;
	Обработчик.ОбщиеДанные         = Истина;
	Обработчик.НачальноеЗаполнение = Истина;
	Обработчик.Процедура           = "ОбновлениеИнформационнойБазыСлужебныйВМоделиСервиса.ПеренестиПаролиВБезопасноеХранилище";
	
КонецПроцедуры

// См. СтандартныеПодсистемыСервер.ПроверитьСоставПланаОбмена.
Процедура ПриПолученииОбъектовИсключенийПланаОбмена(Объекты, Знач РаспределеннаяИнформационнаяБаза) Экспорт
	
	Если РаспределеннаяИнформационнаяБаза Тогда
		
		Объекты.Добавить(Метаданные.РегистрыСведений.ВерсииПодсистемОбластейДанных);
		
	КонецЕсли;
	
КонецПроцедуры

// См. ВыгрузкаЗагрузкаДанныхПереопределяемый.ПослеЗагрузкиДанных.
Процедура ПослеЗагрузкиДанных(Контейнер) Экспорт
	
	Сведения = ОбновлениеИнформационнойБазыСлужебный.СведенияОбОбновленииИнформационнойБазы();
	ОбновлениеЗавершено = Сведения.ОтложенноеОбновлениеЗавершеноУспешно;
	Если ОбновлениеЗавершено <> Истина Тогда
		ОбновлениеИнформационнойБазыСлужебный.ПеререгистрироватьДанныеДляОтложенногоОбновления();
	КонецЕсли;
	ОбновлениеИнформационнойБазыСлужебный.ОтметитьРегистрациюОтложенныхОбработчиковОбновления(, Истина);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ ОБНОВЛЕНИЯ ИНФОРМАЦИОННОЙ БАЗЫ

// Переносит данные из регистра сведений УдалитьВерсииПодсистем в регистр
//  сведений ВерсииПодсистемОбластейДанных.
Процедура ПеренестиВерсииПодсистемВоВспомогательныеДанные() Экспорт
	
	Если Не РаботаВМоделиСервиса.РазделениеВключено() Тогда
		Возврат;
	КонецЕсли;
	
	НачатьТранзакцию();
	
	Попытка
		
		Блокировка = Новый БлокировкаДанных();
		Блокировка.Добавить("РегистрСведений.ВерсииПодсистемОбластейДанных");
		Блокировка.Заблокировать();
		
		ТекстЗапроса =
		"ВЫБРАТЬ
		|	ЕСТЬNULL(ВерсииПодсистемОбластейДанных.ОбластьДанныхВспомогательныеДанные, УдалитьВерсииПодсистем.ОбластьДанных) КАК ОбластьДанныхВспомогательныеДанные,
		|	ЕСТЬNULL(ВерсииПодсистемОбластейДанных.ИмяПодсистемы, УдалитьВерсииПодсистем.ИмяПодсистемы) КАК ИмяПодсистемы,
		|	ЕСТЬNULL(ВерсииПодсистемОбластейДанных.Версия, УдалитьВерсииПодсистем.Версия) КАК Версия
		|ИЗ
		|	РегистрСведений.УдалитьВерсииПодсистем КАК УдалитьВерсииПодсистем
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ВерсииПодсистемОбластейДанных КАК ВерсииПодсистемОбластейДанных
		|		ПО УдалитьВерсииПодсистем.ОбластьДанных = ВерсииПодсистемОбластейДанных.ОбластьДанныхВспомогательныеДанные
		|			И УдалитьВерсииПодсистем.ИмяПодсистемы = ВерсииПодсистемОбластейДанных.ИмяПодсистемы
		|ГДЕ
		|	УдалитьВерсииПодсистем.ОбластьДанных <> -1";
		Запрос = Новый Запрос(ТекстЗапроса);
		
		ВерсииПодсистемОбластейДанных = РегистрыСведений.ВерсииПодсистемОбластейДанных.СоздатьНаборЗаписей();
		ВерсииПодсистемОбластейДанных.Загрузить(Запрос.Выполнить().Выгрузить());
		ОбновлениеИнформационнойБазы.ЗаписатьДанные(ВерсииПодсистемОбластейДанных);
		
		НаборУдалитьВерсииПодсистем = РегистрыСведений.УдалитьВерсииПодсистем.СоздатьНаборЗаписей();
		ОбновлениеИнформационнойБазы.ЗаписатьДанные(НаборУдалитьВерсииПодсистем);
		
		ЗафиксироватьТранзакцию();
		
	Исключение
		
		ОтменитьТранзакцию();
		ВызватьИсключение;
		
	КонецПопытки;
	
КонецПроцедуры

// Перенести пароли в безопасное хранилище.
//
Процедура ПеренестиПаролиВБезопасноеХранилище() Экспорт
	
	Если Не ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса.РаботаВМоделиСервиса.УдаленноеАдминистрированиеВМоделиСервиса") Тогда
		Возврат;
	КонецЕсли;
	
	// Для служебного пользователя Менеджера сервиса.
	ИмяСлужебногоПользователяМенеджераСервиса = Константы.УдалитьИмяСлужебногоПользователяМенеджераСервиса.Получить();
	ПарольСлужебногоПользователяМенеджераСервиса = Константы.УдалитьПарольСлужебногоПользователяМенеджераСервиса.Получить();
	Владелец = ОбщегоНазначения.ИдентификаторОбъектаМетаданных("Константа.ВнутреннийАдресМенеджераСервиса");
	УстановитьПривилегированныйРежим(Истина);
	ОбщегоНазначения.ЗаписатьДанныеВБезопасноеХранилище(Владелец, ИмяСлужебногоПользователяМенеджераСервиса, "ИмяСлужебногоПользователяМенеджераСервиса");
	ОбщегоНазначения.ЗаписатьДанныеВБезопасноеХранилище(Владелец, ПарольСлужебногоПользователяМенеджераСервиса, "ПарольСлужебногоПользователяМенеджераСервиса");
	УстановитьПривилегированныйРежим(Ложь);
	Константы.УдалитьИмяСлужебногоПользователяМенеджераСервиса.Установить("");
	Константы.УдалитьПарольСлужебногоПользователяМенеджераСервиса.Установить("");
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обновление областей данных.

// Возвращает ключ записи для регистра сведений ВерсииПодсистемОбластейДанных.
//
// Возвращаемое значение: 
//   РегистрСведенийКлючЗаписи.ВерсииПодсистемОбластейДанных - ключ записи регистра сведений.
//
Функция КлючЗаписиВерсийПодсистем()
	
	ЗначенияКлюча = Новый Структура;
	Если РаботаВМоделиСервиса.ДоступноИспользованиеРазделенныхДанных() Тогда
		ЗначенияКлюча.Вставить("ОбластьДанныхВспомогательныеДанные", РаботаВМоделиСервиса.ЗначениеРазделителяСеанса());
		ЗначенияКлюча.Вставить("ИмяПодсистемы", "");
		КлючЗаписи = РаботаВМоделиСервиса.СоздатьКлючЗаписиРегистраСведенийВспомогательныхДанных(
			РегистрыСведений.ВерсииПодсистемОбластейДанных, ЗначенияКлюча);
	КонецЕсли;
	
	Возврат КлючЗаписи;
	
КонецФункции

// Выбирает все области данных с неактуальными версиями
// и при необходимости формирует фоновые задания по обновлению
// версии в них.
//
// Параметры:
//   БлокироватьОбласти - Булево - устанавливать блокировку сеансов областей данных
//     на время обновления областей,
//   СообщениеБлокировки - Строка - сообщение блокировки.
//
Процедура ЗапланироватьОбновлениеОбластейДанных(Знач БлокироватьОбласти = Истина, Знач СообщениеБлокировки = "")
	
	УстановитьПривилегированныйРежим(Истина);
	
	Если НЕ РаботаВМоделиСервиса.РазделениеВключено() Тогда
		Возврат;
	КонецЕсли;
	
	Если ПустаяСтрока(СообщениеБлокировки) Тогда
		СообщениеБлокировки = Константы.СообщениеБлокировкиПриОбновленииКонфигурации.Получить();
		Если ПустаяСтрока(СообщениеБлокировки) Тогда
			СообщениеБлокировки = НСтр("ru = 'Система заблокирована для выполнения обновления.'");
		КонецЕсли;
	КонецЕсли;
	ПараметрыБлокировки = СоединенияИБ.НовыеПараметрыБлокировкиСоединений();
	ПараметрыБлокировки.Начало = ТекущаяУниверсальнаяДата();
	ПараметрыБлокировки.Сообщение = СообщениеБлокировки;
	ПараметрыБлокировки.Установлена = Истина;
	ПараметрыБлокировки.Эксклюзивная = Истина;
	
	ВерсияМетаданных = Метаданные.Версия;
	Если ПустаяСтрока(ВерсияМетаданных) Тогда
		Возврат;
	КонецЕсли;
	
	ВерсияОбщихДанных = ОбновлениеИнформационнойБазыСлужебный.ВерсияИБ(Метаданные.Имя, Истина);
	Если ОбновлениеИнформационнойБазыСлужебный.НеобходимоВыполнитьОбновление(ВерсияМетаданных, ВерсияОбщихДанных) Тогда
		// Не выполнено обновление общих данных смысла планировать
		// обновление областей нет.
		Возврат;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ОбластиДанных.ОбластьДанныхВспомогательныеДанные КАК ОбластьДанных
	|ИЗ
	|	РегистрСведений.ОбластиДанных КАК ОбластиДанных
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ВерсииПодсистемОбластейДанных КАК ВерсииПодсистемОбластейДанных
	|		ПО ОбластиДанных.ОбластьДанныхВспомогательныеДанные = ВерсииПодсистемОбластейДанных.ОбластьДанныхВспомогательныеДанные
	|			И (ВерсииПодсистемОбластейДанных.ИмяПодсистемы = &ИмяПодсистемы)
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.РейтингАктивностиОбластейДанных КАК РейтингАктивностиОбластейДанных
	|		ПО ОбластиДанных.ОбластьДанныхВспомогательныеДанные = РейтингАктивностиОбластейДанных.ОбластьДанныхВспомогательныеДанные
	|ГДЕ
	|	ОбластиДанных.Статус В (ЗНАЧЕНИЕ(Перечисление.СтатусыОбластейДанных.Используется))
	|	И ЕСТЬNULL(ВерсииПодсистемОбластейДанных.Версия, """") <> &Версия
	|
	|УПОРЯДОЧИТЬ ПО
	|	ЕСТЬNULL(РейтингАктивностиОбластейДанных.Рейтинг, 9999999),
	|	ОбластьДанных";
	Запрос.УстановитьПараметр("ИмяПодсистемы", Метаданные.Имя);
	Запрос.УстановитьПараметр("Версия", ВерсияМетаданных);
	Результат = РаботаВМоделиСервиса.ВыполнитьЗапросВнеТранзакции(Запрос);
	Если Результат.Пустой() Тогда // Предварительное чтение, возможно с проявлениями грязного чтения.
		Возврат;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	ОбластиДанных.Статус КАК Статус
	|ИЗ
	|	РегистрСведений.ОбластиДанных КАК ОбластиДанных
	|ГДЕ
	|	ОбластиДанных.ОбластьДанныхВспомогательныеДанные = &ОбластьДанных
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ ПЕРВЫЕ 1
	|	ВерсииПодсистемОбластейДанных.Версия КАК Версия
	|ИЗ
	|	РегистрСведений.ВерсииПодсистемОбластейДанных КАК ВерсииПодсистемОбластейДанных
	|ГДЕ
	|	ВерсииПодсистемОбластейДанных.ОбластьДанныхВспомогательныеДанные = &ОбластьДанных
	|	И ВерсииПодсистемОбластейДанных.ИмяПодсистемы = &ИмяПодсистемы";
	Запрос.УстановитьПараметр("ИмяПодсистемы", Метаданные.Имя);
	
	Выборка = Результат.Выбрать();
	Пока Выборка.Следующий() Цикл
		ЗначенияКлюча = Новый Структура;
		ЗначенияКлюча.Вставить("ОбластьДанныхВспомогательныеДанные", Выборка.ОбластьДанных);
		ЗначенияКлюча.Вставить("ИмяПодсистемы", "");
		КлючЗаписи = РаботаВМоделиСервиса.СоздатьКлючЗаписиРегистраСведенийВспомогательныхДанных(
			РегистрыСведений.ВерсииПодсистемОбластейДанных, ЗначенияКлюча);
		
		ОшибкаУстановкиБлокировки = Ложь;
		
		НачатьТранзакцию();
		Попытка
			Попытка
				ЗаблокироватьДанныеДляРедактирования(КлючЗаписи); // Будет снята при окончании транзакции.
			Исключение
				ОшибкаУстановкиБлокировки = Истина;
				ВызватьИсключение;
			КонецПопытки;
			
			Запрос.УстановитьПараметр("ОбластьДанных", Выборка.ОбластьДанных);
		
			Блокировка = Новый БлокировкаДанных;
			
			ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.ВерсииПодсистемОбластейДанных");
			ЭлементБлокировки.УстановитьЗначение("ОбластьДанныхВспомогательныеДанные", Выборка.ОбластьДанных);
			ЭлементБлокировки.УстановитьЗначение("ИмяПодсистемы", Метаданные.Имя);
			ЭлементБлокировки.Режим = РежимБлокировкиДанных.Разделяемый;
			
			ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.ОбластиДанных");
			ЭлементБлокировки.УстановитьЗначение("ОбластьДанныхВспомогательныеДанные", Выборка.ОбластьДанных);
			ЭлементБлокировки.Режим = РежимБлокировкиДанных.Разделяемый;
			
			Блокировка.Заблокировать();
			
			Результаты = Запрос.ВыполнитьПакет();
			
			СтрокаОбласти = Неопределено;
			Если НЕ Результаты[0].Пустой() Тогда
				СтрокаОбласти = Результаты[0].Выгрузить()[0];
			КонецЕсли;
			СтрокаВерсии = Неопределено;
			Если НЕ Результаты[1].Пустой() Тогда
				СтрокаВерсии = Результаты[1].Выгрузить()[0];
			КонецЕсли;
			
			Если СтрокаОбласти = Неопределено
				ИЛИ СтрокаОбласти.Статус <> Перечисления.СтатусыОбластейДанных.Используется
				ИЛИ (СтрокаВерсии <> Неопределено И СтрокаВерсии.Версия = ВерсияМетаданных) Тогда
				
				// Записи не соответствуют исходному критерию.
				ЗафиксироватьТранзакцию();
				Продолжить;
			КонецЕсли;
			
			ОтборЗадания = Новый Структура;
			ОтборЗадания.Вставить("ИмяМетода", "ОбновлениеИнформационнойБазыСлужебныйВМоделиСервиса.ВыполнитьОбновлениеТекущейОбластиДанных");
			ОтборЗадания.Вставить("Ключ", "1");
			ОтборЗадания.Вставить("ОбластьДанных", Выборка.ОбластьДанных);
			Задания = ОчередьЗаданий.ПолучитьЗадания(ОтборЗадания);
			Если Задания.Количество() > 0 Тогда
				// Уже есть задание обновления области.
				ЗафиксироватьТранзакцию();
				Продолжить;
			КонецЕсли;
			
			ПараметрыЗадания = Новый Структура;
			ПараметрыЗадания.Вставить("ИмяМетода"    , "ОбновлениеИнформационнойБазыСлужебныйВМоделиСервиса.ВыполнитьОбновлениеТекущейОбластиДанных");
			ПараметрыЗадания.Вставить("Параметры"    , Новый Массив);
			ПараметрыЗадания.Вставить("Ключ"         , "1");
			ПараметрыЗадания.Вставить("ОбластьДанных", Выборка.ОбластьДанных);
			ПараметрыЗадания.Вставить("ЭксклюзивноеВыполнение", Истина);
			ПараметрыЗадания.Вставить("КоличествоПовторовПриАварийномЗавершении", 3);
			
			ОчередьЗаданий.ДобавитьЗадание(ПараметрыЗадания);
			
			Если БлокироватьОбласти Тогда
				СоединенияИБ.УстановитьБлокировкуСеансовОбластиДанных(ПараметрыБлокировки, Ложь, Выборка.ОбластьДанных);
			КонецЕсли;
			
			ЗафиксироватьТранзакцию();
			
		Исключение
			
			ОтменитьТранзакцию();
			Если ОшибкаУстановкиБлокировки Тогда
				Продолжить;
			Иначе
				ВызватьИсключение;
			КонецЕсли;
			
		КонецПопытки;
		
	КонецЦикла;
	
КонецПроцедуры

// Выполняет обновление версии информационной базы в текущей области данных
// и снимает блокировку сеансов в области, в случае если она была установлена
// ранее.
//
Процедура ВыполнитьОбновлениеТекущейОбластиДанных() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	ОбновлениеИнформационнойБазы.ВыполнитьОбновлениеИнформационнойБазы();
	
КонецПроцедуры

// Обработчик регламентного задания ОбновлениеОбластейДанных.
// Выбирает все области данных с неактуальными версиями
// и при необходимости формирует фоновые задания ОбновлениеИБ в них.
//
Процедура ОбновлениеОбластейДанных() Экспорт
	
	Если НЕ РаботаВМоделиСервиса.РазделениеВключено() Тогда
		Возврат;
	КонецЕсли;
	
	// Вызов ПриНачалеВыполненияРегламентногоЗадания не используется,
	// т.к. необходимые действия выполняются в частном порядке.
	
	ЗапланироватьОбновлениеОбластейДанных(Истина);
	
КонецПроцедуры

// Только для внутреннего использования.
Функция МинимальнаяВерсияОбластейДанных() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Если РаботаВМоделиСервиса.РазделениеВключено() И РаботаВМоделиСервиса.ДоступноИспользованиеРазделенныхДанных() Тогда
		ВызватьИсключение НСтр("ru = 'Вызов функции ОбновлениеИнформационнойБазыСлужебныйПовтИсп.МинимальнаяВерсияОбластейДанных()
		                             |недоступен из сеансов с установленным значением разделителей модели сервиса.'");
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ИмяПодсистемы", Метаданные.Имя);
	Запрос.Текст =
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ВерсииПодсистемОбластейДанных.Версия КАК Версия
	|ИЗ
	|	РегистрСведений.ВерсииПодсистемОбластейДанных КАК ВерсииПодсистемОбластейДанных
	|ГДЕ
	|	ВерсииПодсистемОбластейДанных.ИмяПодсистемы = &ИмяПодсистемы";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	МинимальнаяВерсияИБ = Неопределено;
	
	Пока Выборка.Следующий() Цикл
		Если ОбщегоНазначенияКлиентСервер.СравнитьВерсии(Выборка.Версия, МинимальнаяВерсияИБ) > 0 Тогда
			МинимальнаяВерсияИБ = Выборка.Версия;
		КонецЕсли
	КонецЦикла;
	
	Возврат МинимальнаяВерсияИБ;
	
КонецФункции

// Только для внутреннего использования.
Процедура УстановитьВерсиюВсехОбластейДанных(ИдентификаторБиблиотеки, ИсходнаяВерсияИБ, ВерсияМетаданныхИБ)
	
	Блокировка = Новый БлокировкаДанных;
	Блокировка.Добавить("РегистрСведений.ВерсииПодсистемОбластейДанных");
	Блокировка.Добавить("РегистрСведений.ОбластиДанных");
	
	НачатьТранзакцию();
	Попытка
		Блокировка.Заблокировать();
		
		Запрос = Новый Запрос;
		Запрос.Текст =
		"ВЫБРАТЬ
		|	ОбластиДанных.ОбластьДанныхВспомогательныеДанные КАК ОбластьДанных
		|ИЗ
		|	РегистрСведений.ОбластиДанных КАК ОбластиДанных
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ВерсииПодсистемОбластейДанных КАК ВерсииПодсистемОбластейДанных
		|		ПО ОбластиДанных.ОбластьДанныхВспомогательныеДанные = ВерсииПодсистемОбластейДанных.ОбластьДанныхВспомогательныеДанные
		|ГДЕ
		|	ОбластиДанных.Статус = ЗНАЧЕНИЕ(Перечисление.СтатусыОбластейДанных.Используется)
		|	И ВерсииПодсистемОбластейДанных.ИмяПодсистемы = &ИмяПодсистемы
		|	И ВерсииПодсистемОбластейДанных.Версия = &Версия";
		Запрос.УстановитьПараметр("ИмяПодсистемы", ИдентификаторБиблиотеки);
		Запрос.УстановитьПараметр("Версия", ИсходнаяВерсияИБ);
		
		Выборка = Запрос.Выполнить().Выбрать();
		Пока Выборка.Следующий() Цикл
			МенеджерЗаписи = РегистрыСведений.ВерсииПодсистемОбластейДанных.СоздатьМенеджерЗаписи();
			МенеджерЗаписи.ОбластьДанныхВспомогательныеДанные = Выборка.ОбластьДанных;
			МенеджерЗаписи.ИмяПодсистемы = ИдентификаторБиблиотеки;
			МенеджерЗаписи.Версия = ВерсияМетаданныхИБ;
			МенеджерЗаписи.Записать();
		КонецЦикла;
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

#КонецОбласти
