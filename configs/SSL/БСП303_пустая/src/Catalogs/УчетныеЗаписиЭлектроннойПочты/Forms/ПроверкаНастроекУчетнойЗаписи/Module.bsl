
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Элементы.Страницы.ТекущаяСтраница = Элементы.ВыполняетсяПроверкаНастроек;
	Элементы.ФормаЗакрыть.Заголовок = НСтр("ru = 'Отмена'");
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ПодключитьОбработчикОжидания("ВыполнитьПроверкуНастроек", 0.1, Истина)
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура НужнаПомощьНажатие(Элемент)
	РаботаСПочтовымиСообщениямиКлиент.ПерейтиКДокументацииПоВводуУчетнойЗаписиЭлектроннойПочты();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ВыполнитьПроверкуНастроек()
	ДлительнаяОперация = НачатьВыполнениеНаСервере();
	ОповещениеОЗавершении = Новый ОписаниеОповещения("ОбработатьРезультат", ЭтотОбъект);
	ПараметрыОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
	ПараметрыОжидания.ВыводитьОкноОжидания = Ложь;
	ДлительныеОперацииКлиент.ОжидатьЗавершение(ДлительнаяОперация, ОповещениеОЗавершении, ПараметрыОжидания);
КонецПроцедуры

&НаСервере
Функция НачатьВыполнениеНаСервере()
	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияВФоне(УникальныйИдентификатор);
	Возврат ДлительныеОперации.ВыполнитьВФоне("Справочники.УчетныеЗаписиЭлектроннойПочты.ПроверитьНастройкиУчетнойЗаписиВФоне",
		Новый Структура("УчетнаяЗапись", Параметры.УчетнаяЗапись), ПараметрыВыполнения);
КонецФункции

&НаКлиенте
Процедура ОбработатьРезультат(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Элементы.ФормаЗакрыть.Заголовок = НСтр("ru = 'Закрыть'");
	
	Если Результат.Статус = "Ошибка" Тогда
		ВызватьИсключение Результат.КраткоеПредставлениеОшибки;
	КонецЕсли;
	
	РезультатПроверки = ПолучитьИзВременногоХранилища(Результат.АдресРезультата);
	СообщенияОбОшибках = РезультатПроверки.ОшибкиПодключения;
	ВыполненныеПроверки = РезультатПроверки.ВыполненныеПроверки;
	Если ЗначениеЗаполнено(СообщенияОбОшибках) Тогда
		Элементы.Страницы.ТекущаяСтраница = Элементы.ПриПроверкеОбнаруженыОшибки;
	Иначе
		Элементы.Страницы.ТекущаяСтраница = Элементы.ПроверкаУспешноВыполнена;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
