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
	
	ФормулировкиЭлементарныхВопросов = Новый Соответствие;
	
	Если  ОбработатьВходящиеПараметры(ФормулировкиЭлементарныхВопросов) Тогда
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
	СформироватьОтчет(ФормулировкиЭлементарныхВопросов);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура СформироватьОтчет(ФормулировкиЭлементарныхВопросов)

	ТаблицаОтчета.Очистить();
	
	РезультатЗапроса = ВыполнитьЗапросПоВопросуАнкеты();
	Если РезультатЗапроса.Пустой() Тогда
		Возврат;
	КонецЕсли;
	
	Макет = Отчеты.АнализОпроса.ПолучитьМакет("МакетОтветы");
	
	Область = Макет.ПолучитьОбласть("Вопрос");
	Область.Параметры.ФормулировкаВопроса = Формулировка;
	ТаблицаОтчета.Вывести(Область,1);
	
	ДеревоОтветов = РезультатЗапроса.Выгрузить(ОбходРезультатаЗапроса.ПоГруппировкам);
	Для каждого СтрокаДерева Из ДеревоОтветов.Строки Цикл
		ВывестиВДокументРеспондентов(СтрокаДерева,Макет,ФормулировкиЭлементарныхВопросов);
	КонецЦикла;

КонецПроцедуры

&НаСервере
Процедура ВывестиВДокументРеспондентов(СтрокаДерева,Макет, ФормулировкиЭлементарныхВопросов)

	Область = Макет.ПолучитьОбласть("Респондент");
	Область.Параметры.Респондент = СтрокаДерева.Респондент;
	ТаблицаОтчета.Вывести(Область,1);
	
	ТаблицаОтчета.НачатьГруппуСтрок(СтрокаДерева.Респондент);
	ВывестиТабличныйОтвет(СтрокаДерева,Макет,ФормулировкиЭлементарныхВопросов);
	ТаблицаОтчета.ЗакончитьГруппуСтрок();

КонецПроцедуры

&НаСервере
Процедура ВывестиТабличныйОтвет(СтрокаДерева,Макет,ФормулировкиЭлементарныхВопросов)

	Если ТипТабличногоВопроса = Перечисления.ТипыТабличныхВопросов.Составной Тогда
		
		ВывестиОтветСоставнойТабличныйВопрос(СтрокаДерева,Макет,ФормулировкиЭлементарныхВопросов);
		
	ИначеЕсли ТипТабличногоВопроса = Перечисления.ТипыТабличныхВопросов.ПредопределенныеОтветыВКолонках Тогда
		
		ВывестиОтветПредопределенныеОтветыВКолонкахТабличныйВопрос(СтрокаДерева,Макет, ФормулировкиЭлементарныхВопросов);
		
	ИначеЕсли ТипТабличногоВопроса = Перечисления.ТипыТабличныхВопросов.ПредопределенныеОтветыВСтроках Тогда
		
		ВывестиОтветПредопределенныеОтветыВСтрокахТабличныйВопрос(СтрокаДерева,Макет, ФормулировкиЭлементарныхВопросов);
		
	ИначеЕсли ТипТабличногоВопроса = Перечисления.ТипыТабличныхВопросов.ПредопределенныеОтветыВСтрокахИКолонках Тогда
		
		ВывестиОтветПредопределенныеОтветыВСтрокахИКолонкахТабличныйВопрос(СтрокаДерева,Макет);
		
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура ВывестиОтветСоставнойТабличныйВопрос(СтрокаДерева,Макет, ФормулировкиЭлементарныхВопросов)
	
	ПерваяКолонка = Истина;
	
	Для каждого Вопрос Из СоставТабличногоВопроса Цикл
		
		Если ПерваяКолонка Тогда
			Область = Макет.ПолучитьОбласть("Отступ");
			ТаблицаОтчета.Вывести(Область);
			ПерваяКолонка = Ложь;
		КонецЕсли;
		
		Область = Макет.ПолучитьОбласть("ЭлементШапкиТабличногоВопроса");
		Область.Параметры.Значение = ФормулировкиЭлементарныхВопросов.Получить(Вопрос.ЭлементарныйВопрос);
		ТаблицаОтчета.Присоединить(Область);
		
	КонецЦикла; 
	
	ПерваяКолонка = Истина;
	
	Для каждого СтрокаДереваЯчейка Из СтрокаДерева.Строки Цикл
		
		ПерваяКолонка = Истина;
		
		Для каждого СтрокаСоставаТабличногоВопроса Из СоставТабличногоВопроса Цикл
			
			НайденнаяСтрока = СтрокаДереваЯчейка.Строки.Найти(СтрокаСоставаТабличногоВопроса.ЭлементарныйВопрос,"ЭлементарныйВопрос");
			
			Если ПерваяКолонка Тогда
				Область = Макет.ПолучитьОбласть("Отступ");
				ТаблицаОтчета.Вывести(Область);
				ПерваяКолонка = Ложь;
			КонецЕсли;
			
			Область = Макет.ПолучитьОбласть("ЯчейкаТабличногоВопроса");
			Область.Параметры.Значение = ?(НайденнаяСтрока = Неопределено,"",НайденнаяСтрока.Ответ);
			ТаблицаОтчета.Присоединить(Область);
			
		КонецЦикла;
		
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ВывестиОтветПредопределенныеОтветыВКолонкахТабличныйВопрос(СтрокаДерева,Макет, ФормулировкиЭлементарныхВопросов)

	Область = Макет.ПолучитьОбласть("Отступ");
	ТаблицаОтчета.Вывести(Область);
	
	Область = Макет.ПолучитьОбласть("ЭлементШапкиТабличногоВопроса");
	ТаблицаОтчета.Присоединить(Область);
	
	Для Каждого Ответ Из ПредопределенныеОтветы Цикл
		
		Область = Макет.ПолучитьОбласть("ЭлементШапкиТабличногоВопроса");
		Область.Параметры.Значение = Ответ.Ответ;
		ТаблицаОтчета.Присоединить(Область);
		
	КонецЦикла;	
	
	Для ИндексСтрок = 2 По СоставТабличногоВопроса.Количество() Цикл
		
		Область = Макет.ПолучитьОбласть("Отступ");
		ТаблицаОтчета.Вывести(Область);
		
		Область = Макет.ПолучитьОбласть("ЭлементШапкиТабличногоВопроса");
		Область.Параметры.Значение = ФормулировкиЭлементарныхВопросов.Получить(СоставТабличногоВопроса[ИндексСтрок - 1].ЭлементарныйВопрос);
		ТаблицаОтчета.Присоединить(Область);
		
		Для ИндексКолонок = 1 По ПредопределенныеОтветы.Количество() Цикл
			
			СтруктураОтбора = Новый Структура;
			СтруктураОтбора.Вставить("ЭлементарныйВопрос", СоставТабличногоВопроса[ИндексСтрок-1].ЭлементарныйВопрос);
			СтруктураОтбора.Вставить("НомерЯчейки",ИндексКолонок);
			НайденныеСтроки = СтрокаДерева.Строки.НайтиСтроки(СтруктураОтбора,Истина);
			
			Область = Макет.ПолучитьОбласть("ЯчейкаТабличногоВопроса");
			Если НайденныеСтроки.Количество() > 0 Тогда
				Область.Параметры.Значение = НайденныеСтроки[0].Ответ;
			КонецЕсли;
			ТаблицаОтчета.Присоединить(Область);
			
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ВывестиОтветПредопределенныеОтветыВСтрокахТабличныйВопрос(СтрокаДерева,Макет, ФормулировкиЭлементарныхВопросов)

	ПерваяКолонка = Истина;
	
	Для каждого Вопрос Из СоставТабличногоВопроса Цикл
		
		Если ПерваяКолонка Тогда
			Область = Макет.ПолучитьОбласть("Отступ");
			ТаблицаОтчета.Вывести(Область);
			ПерваяКолонка = Ложь;
		КонецЕсли;
		
		Область = Макет.ПолучитьОбласть("ЭлементШапкиТабличногоВопроса");
		Область.Параметры.Значение = ФормулировкиЭлементарныхВопросов.Получить(Вопрос.ЭлементарныйВопрос);
		ТаблицаОтчета.Присоединить(Область);
		
	КонецЦикла;
	
	Для каждого СтрокаДереваЯчейка Из СтрокаДерева.Строки Цикл
		
		ПерваяКолонка = Истина;
		
		Для ИндексКолонок = 1 По СоставТабличногоВопроса.Количество() Цикл
			
			Если ПерваяКолонка Тогда
				
				Область = Макет.ПолучитьОбласть("Отступ");
				ТаблицаОтчета.Вывести(Область);
				ПерваяКолонка = Ложь;
				
				Область = Макет.ПолучитьОбласть("ЭлементЯчейкиТабличногоВопросаПредопределенныйОтвет");
				Область.Параметры.Значение = ПредопределенныеОтветы[СтрокаДереваЯчейка.НомерЯчейки - 1].Ответ;
				ТаблицаОтчета.Присоединить(Область);
				
			Иначе
				
				НайденнаяСтрока = СтрокаДереваЯчейка.Строки.Найти(СоставТабличногоВопроса[ИндексКолонок - 1].ЭлементарныйВопрос,"ЭлементарныйВопрос");
				
				Область = Макет.ПолучитьОбласть("ЯчейкаТабличногоВопроса");
				Область.Параметры.Значение = ?(НайденнаяСтрока = Неопределено,"",НайденнаяСтрока.Ответ);

				ТаблицаОтчета.Присоединить(Область);
				
			КонецЕсли;
			
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ВывестиОтветПредопределенныеОтветыВСтрокахИКолонкахТабличныйВопрос(СтрокаДерева,Макет)
	
	ОтветыКолонки = ПредопределенныеОтветы.НайтиСтроки(Новый Структура("ЭлементарныйВопрос",СоставТабличногоВопроса[1].ЭлементарныйВопрос));
	ОтветыСтроки = ПредопределенныеОтветы.НайтиСтроки(Новый Структура("ЭлементарныйВопрос",СоставТабличногоВопроса[0].ЭлементарныйВопрос));
	
	Если ОтветыКолонки.Количество() = 0 И ОтветыСтроки.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Область = Макет.ПолучитьОбласть("Отступ");
	ТаблицаОтчета.Вывести(Область);
	
	Область = Макет.ПолучитьОбласть("ЭлементШапкиТабличногоВопроса");
	ТаблицаОтчета.Присоединить(Область);
	
	Для Каждого Ответ Из ОтветыКолонки Цикл
		
		Область = Макет.ПолучитьОбласть("ЭлементШапкиТабличногоВопроса");
		Область.Параметры.Значение = Ответ.Ответ;
		ТаблицаОтчета.Присоединить(Область);
		
	КонецЦикла;
	
	Для ИндексСтроки = 1 По ОтветыСтроки.Количество()  Цикл
		
		Область = Макет.ПолучитьОбласть("Отступ");
		ТаблицаОтчета.Вывести(Область);
		
		Область = Макет.ПолучитьОбласть("ЭлементШапкиТабличногоВопроса");
		Область.Параметры.Значение = ОтветыСтроки[ИндексСтроки - 1].Ответ;
		ТаблицаОтчета.Присоединить(Область);
		
		Для ИндексКолонки = 1 По ОтветыКолонки.Количество() Цикл
			
			СтруктураОтбора = Новый Структура;
			СтруктураОтбора.Вставить("НомерЯчейки", ИндексКолонки + (ИндексСтроки-1) * ОтветыКолонки.Количество());
			СтруктураОтбора.Вставить("ЭлементарныйВопрос",СоставТабличногоВопроса[2].ЭлементарныйВопрос);
			НайденныеСтроки = СтрокаДерева.Строки.НайтиСтроки(СтруктураОтбора,Истина);
			
			Область = Макет.ПолучитьОбласть("ЯчейкаТабличногоВопроса");
			Если НайденныеСтроки.Количество() > 0 Тогда
				Область.Параметры.Значение = НайденныеСтроки[0].Ответ;
			КонецЕсли;
			ТаблицаОтчета.Присоединить(Область);
			
		КонецЦикла;
		
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Функция ВыполнитьЗапросПоВопросуАнкеты()
	
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	ЕСТЬNULL(ДокументАнкета.Респондент, НЕОПРЕДЕЛЕНО) КАК Респондент,
	|	ОтветыНаВопросыАнкет.НомерЯчейки                  КАК НомерЯчейки,
	|	ОтветыНаВопросыАнкет.ЭлементарныйВопрос           КАК ЭлементарныйВопрос,
	|	ОтветыНаВопросыАнкет.Ответ
	|ИЗ
	|	РегистрСведений.ОтветыНаВопросыАнкет КАК ОтветыНаВопросыАнкет
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.Анкета КАК ДокументАнкета
	|		ПО ОтветыНаВопросыАнкет.Анкета = ДокументАнкета.Ссылка
	|ГДЕ
	|	ОтветыНаВопросыАнкет.Вопрос = &ВопросШаблона
	|	И ДокументАнкета.Опрос = &Опрос
	|
	|УПОРЯДОЧИТЬ ПО
	|	Респондент,
	|	НомерЯчейки
	|ИТОГИ ПО
	|	Респондент,
	|	НомерЯчейки";
	
	Запрос.УстановитьПараметр("ВопросШаблона",ВопросШаблонаАнкеты);
	Запрос.УстановитьПараметр("Опрос",Опрос);
	
	Возврат Запрос.Выполнить();
	
КонецФункции

&НаСервере
Функция ОбработатьВходящиеПараметры(ФормулировкиЭлементарныхВопросов)

	Если Параметры.Свойство("ВопросШаблонаАнкеты") Тогда
		ВопросШаблонаАнкеты = Параметры.ВопросШаблонаАнкеты;
	Иначе
		Возврат Истина;
	КонецЕсли;
	
	Если Параметры.Свойство("Опрос") Тогда
		Опрос = Параметры.Опрос; 
	Иначе
		Возврат Истина;
	КонецЕсли;
	
	Если Параметры.Свойство("ПолныйКод") Тогда
		ПолныйКод =  Параметры.ПолныйКод;
	КонецЕсли;
	
	Если Параметры.Свойство("НаименованиеОпроса") Тогда
		НаименованиеОпроса =  Параметры.НаименованиеОпроса;
	Иначе
		Отказ = Истина;
	КонецЕсли; 
	
	Если Параметры.Свойство("ДатаОпроса") Тогда
		ДатаОпроса =  Параметры.ДатаОпроса;
	Иначе
		Отказ = Истина;
	КонецЕсли;
	
	РеквизитыВопросШаблона = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ВопросШаблонаАнкеты,"ТипТабличногоВопроса,СоставТабличногоВопроса,ПредопределенныеОтветы,Формулировка");
	Формулировка           = РеквизитыВопросШаблона.Формулировка;
	ТипТабличногоВопроса   = РеквизитыВопросШаблона.ТипТабличногоВопроса;
	СоставТабличногоВопроса.Загрузить(РеквизитыВопросШаблона.СоставТабличногоВопроса.Выгрузить());
	ПредопределенныеОтветы.Загрузить(РеквизитыВопросШаблона.ПредопределенныеОтветы.Выгрузить());
	ПолучитьФормулировкиЭлементарныхВопросов(ФормулировкиЭлементарныхВопросов);
	
	Заголовок = НСтр("ru='Ответы на вопрос №'") + " " + ПолныйКод + " " + НСтр("ru='опроса'") + " " + НаименованиеОпроса + " " + НСтр("ru='от'") + " " + Формат(ДатаОпроса,"ДЛФ=D");
	
	Возврат Ложь;

КонецФункции

&НаСервере
Процедура ПолучитьФормулировкиЭлементарныхВопросов(ФормулировкиЭлементарныхВопросов)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ВопросыДляАнкетирования.Ссылка,
	|	ВопросыДляАнкетирования.Формулировка,
	|	ВопросыДляАнкетирования.АгрегироватьСуммуВОтчетах
	|ИЗ
	|	ПланВидовХарактеристик.ВопросыДляАнкетирования КАК ВопросыДляАнкетирования
	|ГДЕ
	|	ВопросыДляАнкетирования.Ссылка В(&МассивВопросов)";
	
	Запрос.УстановитьПараметр("МассивВопросов",СоставТабличногоВопроса.Выгрузить().ВыгрузитьКолонку("ЭлементарныйВопрос"));
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		ФормулировкиЭлементарныхВопросов.Вставить(Выборка.Ссылка,Выборка.Формулировка);
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти
