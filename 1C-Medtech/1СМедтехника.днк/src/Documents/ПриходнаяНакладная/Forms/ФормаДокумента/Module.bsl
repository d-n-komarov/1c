
&НаСервере
Процедура днк_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)
	Если Объект.ВключатьРасходыВСебестоимость Тогда 	
		днк_ДобавитьДнкКоэффициент();
		днк_ПересчитатьДнкКоэффициентСервер();
	КонецЕсли;
	Элементы.ЗапасыРасходыИтогВсего.Видимость = Объект.ВключатьРасходыВСебестоимость;
КонецПроцедуры

&НаКлиенте
Процедура днк_ВключатьРасходыВСебестоимостьПриИзмененииПосле(Элемент)
	Если Объект.ВключатьРасходыВСебестоимость Тогда
		днк_ДобавитьДнкКоэффициент();
		днк_ПересчитатьДнкКоэффициентСервер();
		днк_ПроверитьИтогДнкКоэффициент();
	Иначе
		днк_УдалитьДнкКоэффициент();
	КонецЕсли;
	Элементы.ЗапасыРасходыИтогВсего.Видимость = Объект.ВключатьРасходыВСебестоимость;
КонецПроцедуры

&НаКлиенте
Процедура днк_РасходыЦенаПриИзмененииПосле(Элемент)
	днк_ПересчитатьДнкКоэффициентСервер();
	днк_ПроверитьИтогДнкКоэффициент();
КонецПроцедуры

&НаКлиенте
Процедура днк_РасходыПослеУдаленияПосле(Элемент)
	днк_ПересчитатьДнкКоэффициентСервер();
	днк_ПроверитьИтогДнкКоэффициент();
КонецПроцедуры

&НаКлиенте
Процедура днк_ЗапасыДнкКоэффициентПриИзменении(Элемент)
	ТекущаяСтрока = Элементы.Запасы.ТекущиеДанные;
	ВсегоРасходы = Объект.Расходы.Итог("Всего");
	Если ВсегоРасходы <= 0 Тогда
		ТекущаяСтрока.днкКоэффициент = 0;
		Возврат;
	КонецЕсли;
	
	СуммаКоэффициентов = Объект.Запасы.Итог("днкКоэффициент");
	
	
	ТекущаяСтрока.СуммаРасходов = ТекущаяСтрока.днкКоэффициент / 100 * ВсегоРасходы;
	ИтогДнкКоэффициент = Объект.Запасы.Итог("днкКоэффициент");
	
	днк_ПроверитьИтогДнкКоэффициент();
КонецПроцедуры

&НаКлиенте
Процедура днк_ЗапасыСуммаРасходовПриИзмененииПосле(Элемент)
	днк_ПересчитатьДнкКоэффициентСервер();
	днк_ПроверитьИтогДнкКоэффициент();
КонецПроцедуры

&НаКлиенте
Процедура днк_ЗапасыПослеУдаленияПосле(Элемент)
	днк_ПересчитатьДнкКоэффициентСервер();
	днк_ПроверитьИтогДнкКоэффициент();
КонецПроцедуры

&НаСервере
Процедура днк_ОбработкаПроверкиЗаполненияНаСервереПосле(Отказ, ПроверяемыеРеквизиты)
	Если Объект.ВключатьРасходыВСебестоимость И Объект.Запасы.Итог("днкКоэффициент") <> 100 Тогда
		
		ТекстСообщения = НСтр("ru='Сумма % распределения не равна 100%!';uk='Сума % розподілу не дорівнює 100%!'");
		УправлениеНебольшойФирмойСервер.СообщитьОбОшибке(
			,
			ТекстСообщения,
			Неопределено,
			Неопределено,
			Неопределено,
			Отказ
		);
		
	КонецЕсли;
КонецПроцедуры

&НаСервере
&После("РаспределитьТабЧастьРасходыПоКоличеству")
Процедура днк_РаспределитьТабЧастьРасходыПоКоличеству()
	днк_ПересчитатьДнкКоэффициентСервер();
КонецПроцедуры

&НаСервере
&После("РаспределитьТабЧастьРасходыПоСумме")
Процедура днк_РаспределитьТабЧастьРасходыПоСумме()
	днк_ПересчитатьДнкКоэффициентСервер();
КонецПроцедуры

&НаСервере
Процедура днк_ДобавитьДнкКоэффициент()
	//Добавим в форму новые реквизиты
	новыеРеквизиты = Новый Массив;
	
	новыйРеквизит = Новый РеквизитФормы("днкКоэффициент",
		Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(15,12,ДопустимыйЗнак.Неотрицательный)), "Объект.Запасы", "% от Суммы услуг", Ложь);
	новыеРеквизиты.Добавить(новыйРеквизит);
	
	ИзменитьРеквизиты(новыеРеквизиты);
	
	//Добавим в форму новые элементы и свяжем их с новыми реквизитами
	новыйЭлемент = Элементы.Добавить("ЗапасыДнкКоэффициент", Тип("ПолеФормы"), Элементы.Запасы);
	новыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;
	новыйЭлемент.РежимРедактирования = РежимРедактированияКолонки.ВходПриВводе;
	новыйЭлемент.ОтображатьВПодвале = Истина;
	новыйЭлемент.ПутьКДаннымПодвала = "ИтогДнкКоэффициент";
	новыйЭлемент.ПутьКДанным = "Объект.Запасы.днкКоэффициент";
	//Поставим в нужное место
	Элементы.Переместить(новыйЭлемент, Элементы.Запасы, Элементы.Запасы.ПодчиненныеЭлементы.ЗапасыСуммаРасходов);
	
	//Добавим обработчики событий
	новыйЭлемент.УстановитьДействие("ПриИзменении","днк_ЗапасыДнкКоэффициентПриИзменении");

КонецПроцедуры	

&НаСервере
Процедура днк_УдалитьДнкКоэффициент()
	//Удалим реквизиты
	удаляемыеРеквизиты = Новый Массив;
	
	удаляемыеРеквизиты.Добавить("Объект.Запасы.днкКоэффициент");
	
	ИзменитьРеквизиты(,удаляемыеРеквизиты);
	
	//Удалим соответствующие элементы формы
	ЭтаФорма.Элементы.Удалить(ЭтаФорма.Элементы.ЗапасыДнкКоэффициент);

КонецПроцедуры	

&НаСервере
Процедура днк_ПересчитатьДнкКоэффициентСервер()
	//Заполним проценты
	ВсегоРасходы = Объект.Расходы.Итог("Всего");
	Для Каждого строка Из Объект.Запасы Цикл
		Если ВсегоРасходы <= 0 Тогда 
			строка.днкКоэффициент = 0;
		Иначе 
			строка.днкКоэффициент = строка.СуммаРасходов / ВсегоРасходы * 100;
		КонецЕсли;
	КонецЦикла;
	//Итоги нужно считать программно :(
	ИтогДнкКоэффициент = Объект.Запасы.Итог("днкКоэффициент");
КонецПроцедуры

&НаКлиенте
Процедура днк_ПроверитьИтогДнкКоэффициент()
	ВсегоРасходы = Объект.Расходы.Итог("Всего");
	Элементы.ЗапасыДнкКоэффициент.ЦветФонаПодвала = Новый Цвет();
	Элементы.ЗапасыДнкКоэффициент.ЦветТекстаПодвала = Новый Цвет();
	
	Если ВсегоРасходы <= 0 Тогда Возврат; КонецЕсли;
	
	СуммаКоэффициентов = Объект.Запасы.Итог("днкКоэффициент");
	
	Если СуммаКоэффициентов <> 100 Тогда 
		Элементы.ЗапасыДнкКоэффициент.ЦветФонаПодвала = Новый Цвет(178,34,34);
		Элементы.ЗапасыДнкКоэффициент.ЦветТекстаПодвала = Новый Цвет(255,182,193);
	КонецЕсли;
КонецПроцедуры
