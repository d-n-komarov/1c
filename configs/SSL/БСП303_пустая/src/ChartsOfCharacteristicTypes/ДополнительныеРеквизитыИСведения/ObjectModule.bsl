///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПриКопировании(ОбъектКопирования)
	
	Заголовок = "";
	Имя       = "";
	
КонецПроцедуры

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ОбновлениеИнформационнойБазы.ПроверитьОбъектОбработан(ЭтотОбъект);
	
	// Для общих реквизитов зависимости очищаются.
	Если Не ЭтоДополнительноеСведение
		И Не ЗначениеЗаполнено(НаборСвойств)
		И ЗависимостиДополнительныхРеквизитов.Количество() > 0 Тогда
		ЗависимостиДополнительныхРеквизитов.Очистить();
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если УправлениеСвойствамиСлужебный.ТипЗначенияСодержитЗначенияСвойств(ТипЗначения) Тогда
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("ВладелецЗначений", Ссылка);
		Запрос.Текст =
		"ВЫБРАТЬ
		|	Свойства.Ссылка КАК Ссылка,
		|	Свойства.ТипЗначения КАК ТипЗначения
		|ИЗ
		|	ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения КАК Свойства
		|ГДЕ
		|	Свойства.ВладелецДополнительныхЗначений = &ВладелецЗначений";
		Выборка = Запрос.Выполнить().Выбрать();
		
		Пока Выборка.Следующий() Цикл
			НовыйТипЗначения = Неопределено;
			
			Если ТипЗначения.СодержитТип(Тип("СправочникСсылка.ЗначенияСвойствОбъектов"))
			   И НЕ Выборка.ТипЗначения.СодержитТип(Тип("СправочникСсылка.ЗначенияСвойствОбъектов")) Тогда
				
				НовыйТипЗначения = Новый ОписаниеТипов(
					Выборка.ТипЗначения,
					"СправочникСсылка.ЗначенияСвойствОбъектов",
					"СправочникСсылка.ЗначенияСвойствОбъектовИерархия");
				
			ИначеЕсли ТипЗначения.СодержитТип(Тип("СправочникСсылка.ЗначенияСвойствОбъектовИерархия"))
			        И НЕ Выборка.ТипЗначения.СодержитТип(Тип("СправочникСсылка.ЗначенияСвойствОбъектовИерархия")) Тогда
				
				НовыйТипЗначения = Новый ОписаниеТипов(
					Выборка.ТипЗначения,
					"СправочникСсылка.ЗначенияСвойствОбъектовИерархия",
					"СправочникСсылка.ЗначенияСвойствОбъектов");
				
			КонецЕсли;
			
			Если НовыйТипЗначения <> Неопределено Тогда
				ТекущийОбъект = Выборка.Ссылка.ПолучитьОбъект();
				ТекущийОбъект.ТипЗначения = НовыйТипЗначения;
				ТекущийОбъект.ОбменДанными.Загрузка = Истина;
				ТекущийОбъект.Записать();
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	// Проверка, что изменение пометки удаления произведено не из списка.
	// Наборы дополнительных реквизитов и сведений.
	СвойстваОбъекта = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Ссылка, "ПометкаУдаления");
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	Наборы.Ссылка КАК Ссылка
		|ИЗ
		|	%1 КАК Свойства
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.НаборыДополнительныхРеквизитовИСведений КАК Наборы
		|		ПО (Свойства.Ссылка = Наборы.Ссылка)
		|ГДЕ
		|	Свойства.Свойство = &Свойство
		|	И Свойства.ПометкаУдаления <> &ПометкаУдаления";
	Если ЭтоДополнительноеСведение Тогда
		ИмяТаблицы = "Справочник.НаборыДополнительныхРеквизитовИСведений.ДополнительныеСведения";
	Иначе
		ИмяТаблицы = "Справочник.НаборыДополнительныхРеквизитовИСведений.ДополнительныеРеквизиты";
	КонецЕсли;
	Запрос.Текст = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(Запрос.Текст, ИмяТаблицы);
	Запрос.УстановитьПараметр("Свойство", Ссылка);
	Запрос.УстановитьПараметр("ПометкаУдаления", СвойстваОбъекта.ПометкаУдаления);
	
	Результат = Запрос.Выполнить().Выгрузить();
	
	Для Каждого СтрокаРезультата Из Результат Цикл
		НаборСвойствОбъект = СтрокаРезультата.Ссылка.ПолучитьОбъект();
		Если ЭтоДополнительноеСведение Тогда
			ЗаполнитьЗначенияСвойств(НаборСвойствОбъект.ДополнительныеСведения.Найти(Ссылка, "Свойство"), СвойстваОбъекта);
		Иначе
			ЗаполнитьЗначенияСвойств(НаборСвойствОбъект.ДополнительныеРеквизиты.Найти(Ссылка, "Свойство"), СвойстваОбъекта);
		КонецЕсли;
		
		НаборСвойствОбъект.Записать();
	КонецЦикла;
	
КонецПроцедуры

Процедура ПередУдалением(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Свойство", Ссылка);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	НаборыСвойств.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.НаборыДополнительныхРеквизитовИСведений.ДополнительныеРеквизиты КАК НаборыСвойств
	|ГДЕ
	|	НаборыСвойств.Свойство = &Свойство
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	НаборыСвойств.Ссылка
	|ИЗ
	|	Справочник.НаборыДополнительныхРеквизитовИСведений.ДополнительныеСведения КАК НаборыСвойств
	|ГДЕ
	|	НаборыСвойств.Свойство = &Свойство";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		ТекущийОбъект = Выборка.Ссылка.ПолучитьОбъект();
		// Удаление дополнительных реквизитов.
		Индекс = ТекущийОбъект.ДополнительныеРеквизиты.Количество()-1;
		Пока Индекс >= 0 Цикл
			Если ТекущийОбъект.ДополнительныеРеквизиты[Индекс].Свойство = Ссылка Тогда
				ТекущийОбъект.ДополнительныеРеквизиты.Удалить(Индекс);
			КонецЕсли;
			Индекс = Индекс - 1;
		КонецЦикла;
		// Удаление дополнительных сведений.
		Индекс = ТекущийОбъект.ДополнительныеСведения.Количество()-1;
		Пока Индекс >= 0 Цикл
			Если ТекущийОбъект.ДополнительныеСведения[Индекс].Свойство = Ссылка Тогда
				ТекущийОбъект.ДополнительныеСведения.Удалить(Индекс);
			КонецЕсли;
			Индекс = Индекс - 1;
		КонецЦикла;
		Если ТекущийОбъект.Модифицированность() Тогда
			ТекущийОбъект.ОбменДанными.Загрузка = Истина;
			ТекущийОбъект.Записать();
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Процедура ПриЧтенииПредставленийНаСервере() Экспорт
	ЛокализацияСервер.ПриЧтенииПредставленийНаСервере(ЭтотОбъект);
КонецПроцедуры

#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли