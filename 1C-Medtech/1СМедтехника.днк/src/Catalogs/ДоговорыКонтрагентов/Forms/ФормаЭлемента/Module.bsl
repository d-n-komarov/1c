
&НаСервере
Процедура днк_ОбработкаПроверкиЗаполненияНаСервереПосле(Отказ, ПроверяемыеРеквизиты)
    Документ = ДанныеФормыВЗначение(Объект, Тип("СправочникОбъект.ДоговорыКонтрагентов"));
    УстановитьСоответствиеОбъектаИРеквизитаФормы(Документ, "Объект");
	Если (Документ.ВидДоговора = Перечисления.ВидыДоговоров.СПокупателем) И НЕ ЗначениеЗаполнено(Документ.СрокОплатыПокупателя) Тогда
	   	Сообщение = Новый СообщениеПользователю();
   		Сообщение.Текст =  НСтр("ru='Необходимо указать допустимую отсрочку оплаты!';uk='Необхідно вказати допустиму відстрочку оплати!'");
	   	Сообщение.Поле = "СрокОплатыПокупателя";
	   	Сообщение.УстановитьДанные(Документ);
	   	Сообщение.Сообщить();
	   	Отказ = Истина;
	КонецЕсли;
КонецПроцедуры
