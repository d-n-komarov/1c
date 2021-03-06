
&НаКлиентеНаСервереБезКонтекста
&Вместо("ИННиЕДРПОУКорректны")
Функция днк_ИННиЕДРПОУКорректны(Форма)

	Объект = Форма.Объект;
	ЭтоЮрЛицо = ЭтоЮрЛицо(Объект.ВидКонтрагента) Или (Объект.ВидКонтрагента = ПредопределенноеЗначение("Перечисление.ВидыКонтрагентов.ИндивидуальныйПредприниматель"));

	Если ЭтоЮрЛицо Тогда
		Результат = НЕ ПустаяСтрока(Объект.КодПоЕДРПОУ) И Объект.ЕДРПОУВведенКорректно;
	Иначе
		Результат = НЕ ПустаяСтрока(Объект.ИНН) И Объект.ИННВведенКорректно;
	КонецЕсли;

	Возврат Результат;

КонецФункции

&НаКлиентеНаСервереБезКонтекста
&Вместо("СформироватьПредставлениеПроверкиДублей")
Процедура днк_СформироватьПредставлениеПроверкиДублей(Форма)
	
	Объект = Форма.Объект;
	ОписаниеОшибки = "";
	
	Если ИННиЕДРПОУКорректны(Форма) Тогда
		
		
		МассивДублей = ПолучитьДублиКонтрагентаСервер(СокрЛП(Объект.ИНН), СокрЛП(Объект.КодПоЕДРПОУ), Объект.Ссылка);
		
		КоличествоДублей = МассивДублей.Количество();
		
		Если КоличествоДублей > 0 Тогда
			
			СтруктураПараметровСообщенияОДублях = Новый Структура;
			СтруктураПараметровСообщенияОДублях.Вставить("ИННиЕДРПОУ", ?(ЭтоЮрЛицо(Объект.ВидКонтрагента), НСтр("ru='ИНН и ЕГРПОУ';uk='ІПН і ЄДРПОУ'"), НСтр("ru='ИНН';uk='ІПН'")));
			
			Если КоличествоДублей = 1 Тогда
				СтруктураПараметровСообщенияОДублях.Вставить("КоличествоДублей", НСтр("ru='один';uk='один'"));
				СтруктураПараметровСообщенияОДублях.Вставить("СклонениеКонтрагентов", НСтр("ru='контрагент';uk='контрагент'"));
			ИначеЕсли КоличествоДублей < 5 Тогда
				СтруктураПараметровСообщенияОДублях.Вставить("КоличествоДублей", КоличествоДублей);
				СтруктураПараметровСообщенияОДублях.Вставить("СклонениеКонтрагентов", НСтр("ru='контрагента';uk='контрагента'"));
			Иначе
				СтруктураПараметровСообщенияОДублях.Вставить("КоличествоДублей", КоличествоДублей);
				СтруктураПараметровСообщенияОДублях.Вставить("СклонениеКонтрагентов", НСтр("ru='контрагентов';uk='контрагентів'"));
			КонецЕсли;
			
			ОписаниеОшибки = НСтр("ru='С таким [ИННиЕДРПОУ] есть [КоличествоДублей] [СклонениеКонтрагентов]';uk='З таким [ИННиЕДРПОУ] є [КоличествоДублей] [СклонениеКонтрагентов]'");
			ОписаниеОшибки = СтроковыеФункцииКлиентСервер.ВставитьПараметрыВСтроку(ОписаниеОшибки, СтруктураПараметровСообщенияОДублях);
			
		КонецЕсли;
	КонецЕсли;
	
	Форма.ПредставлениеПроверкиДублей = Новый ФорматированнаяСтрока(ОписаниеОшибки, , Форма.ЦветТекстаНекорректногоКонтрагента, , "ПоказатьДубли");
	
КонецПроцедуры

&НаКлиенте
&После("УправлениеФормой")
Процедура днк_УправлениеФормой()
	Если Объект.ВидКонтрагента = ПредопределенноеЗначение("Перечисление.ВидыКонтрагентов.ЮридическоеЛицо") Тогда
		
		Элементы.КодПоЕДРПОУ.ПодсказкаВвода					= НСтр("ru='8 цифр';uk='8 цифр'");
		Элементы.КодПоЕДРПОУ.ОграничениеТипа				= Новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(10));
		
	КонецЕсли;
	Если Объект.ВидКонтрагента = ПредопределенноеЗначение("Перечисление.ВидыКонтрагентов.ИндивидуальныйПредприниматель") Тогда
		
		Элементы.КодПоЕДРПОУ.ПодсказкаВвода					= НСтр("ru='10 цифр';uk='10 цифр'");
		Элементы.КодПоЕДРПОУ.ОграничениеТипа				= Новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(10));
		
	КонецЕсли;
КонецПроцедуры
