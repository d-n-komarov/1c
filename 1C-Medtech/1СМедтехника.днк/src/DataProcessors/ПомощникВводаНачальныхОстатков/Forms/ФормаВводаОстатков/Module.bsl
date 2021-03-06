
&НаСервере
&Перед("ЗаписатьИзмененияФормы")
Процедура днк_ЗаписатьИзмененияФормы(ЗакончитьВвод, Отказ)
	Если СохранятьЗапасы() Тогда
		ВалютаСебестоимости = ВидЦенСебестоимости.ВалютаЦены;
		Если ВалютаУчета <> ВалютаСебестоимости Тогда 
			Для каждого ТекСтрока Из ВводНачальныхОстатковТовары.Запасы Цикл
		
				ТекСтрока.Сумма = ПересчитатьИзВалютыВВалютуУчета(
					ТекСтрока.Сумма,
					ВалютаСебестоимости,
					ДатаОстатков
				);
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаСервере
&После("ЗагрузитьВводыОстатков")
Процедура днк_ЗагрузитьВводыОстатков()
			ЗаполнитьЦены(, Ложь, Ложь);
КонецПроцедуры
