///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем ДополнительнаяИнформация;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ЭтоНовый = Объект.Ссылка.Пустая();
	
	Если ЭтоНовый Тогда
		Параметры.ПоказатьДиалогЗагрузкиИзФайлаПриОткрытии = Истина;
	КонецЕсли;
	
	УстановитьВидимостьДоступность();
	
	Если Не ПравоДоступа("Редактирование", Метаданные.Справочники.ВнешниеКомпоненты) Тогда
		
		Элементы.ФормаОбновитьИзФайла.Видимость = Ложь;
		Элементы.ФормаСохранитьКак.Видимость = Ложь;
		Элементы.ОбновитьСПортала1СИТС.Видимость = Ложь;
		
	КонецЕсли;
	
	Если Не ВнешниеКомпонентыСлужебный.ДоступнаЗагрузкаСПортала() Тогда 
		
		Элементы.ОбновлятьСПортала1СИТС.Видимость = Ложь;
		Элементы.ОбновитьСПортала1СИТС.Видимость = Ложь;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если Параметры.ПоказатьДиалогЗагрузкиИзФайлаПриОткрытии Тогда
		ПодключитьОбработчикОжидания("ЗагрузитьКомпонентуИзФайла", 0.1, Истина);
	КонецЕсли
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	// Если вызвана команда "Перечитать" необходимо удалить буфер данных компоненты
	Если ЭтоАдресВременногоХранилища(АдресДвоичныхДанныхКомпоненты) Тогда
		УдалитьИзВременногоХранилища(АдресДвоичныхДанныхКомпоненты);
	КонецЕсли;
	
	АдресДвоичныхДанныхКомпоненты = Неопределено;
	УстановитьВидимостьДоступность();
	
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	// Если есть двоичные данные компоненты, которые надо сохранить, то помещаем их в ДополнительныеСвойства.
	Если ЭтоАдресВременногоХранилища(АдресДвоичныхДанныхКомпоненты) Тогда
		ДвоичныеДанныеКомпоненты = ПолучитьИзВременногоХранилища(АдресДвоичныхДанныхКомпоненты);
		ТекущийОбъект.ДополнительныеСвойства.Вставить("ДвоичныеДанныеКомпоненты", ДвоичныеДанныеКомпоненты);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПриЗаписиНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	Записана = Истина; // Факт записи свидетельствует положительный результат при закрытии отдельно от записи.
	Параметры.ПоказатьДиалогЗагрузкиИзФайлаПриОткрытии = Ложь; // Избежание закрытия формы при ошибке.
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	УстановитьВидимостьДоступность();
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Если ЗавершениеРаботы Тогда 
		Возврат;
	КонецЕсли;
	
	СтандартнаяОбработка = Ложь;
	
	ПараметрЗакрытия = ВнешниеКомпонентыСлужебныйКлиент.РезультатЗагрузкиКомпоненты();
	ПараметрЗакрытия.Загружена = Записана;
	ПараметрЗакрытия.Идентификатор = Объект.Идентификатор;
	ПараметрЗакрытия.Версия = Объект.Версия;
	ПараметрЗакрытия.Наименование  = Объект.Наименование;
	ПараметрЗакрытия.ДополнительнаяИнформация = ДополнительнаяИнформация;
	
	Закрыть(ПараметрЗакрытия);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ИспользованиеПриИзменении(Элемент)
	
	УстановитьВидимостьДоступность();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновлятьСПортала1СИТСПриИзменении(Элемент)
	
	УстановитьВидимостьДоступность();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОбновитьСПортала(Команда)
	
	Если Модифицированность Тогда
		Оповещение = Новый ОписаниеОповещения("ПослеЗакрытияВопросаЗаписатьОбъект", ЭтотОбъект);
		ПоказатьВопрос(Оповещение, 
			НСтр("ru = 'Для проверки обновления необходимо записать объект. Записать?'"),
			РежимДиалогаВопрос.ДаНет);
	Иначе 
		НачатьОбновлениеКомпонентыСПортала();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьИзФайла(Команда)
	
	ОчиститьСообщения();
	ЗагрузитьКомпонентуИзФайла();
	
КонецПроцедуры

&НаКлиенте
Процедура СохранитьКак(Команда)
	
	Если ЭтоАдресВременногоХранилища(АдресДвоичныхДанныхКомпоненты) Тогда
		ПоказатьПредупреждение(, НСтр("ru = 'Перед сохранение компоненты в файл элемент справочника нужно записать.'"));
	Иначе 
		ОчиститьСообщения();
		ВнешниеКомпонентыСлужебныйКлиент.СохранитьКомпонентуВФайл(Объект.Ссылка);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПоддерживаемыеКлиентскиеПриложения(Команда)
	
	Реквизиты = Новый Структура;
	Реквизиты.Вставить("Windows_x86");
	Реквизиты.Вставить("Windows_x86_64");
	Реквизиты.Вставить("Linux_x86");
	Реквизиты.Вставить("Linux_x86_64");
	Реквизиты.Вставить("Windows_x86_Firefox");
	Реквизиты.Вставить("Linux_x86_Firefox");
	Реквизиты.Вставить("Linux_x86_64_Firefox");
	Реквизиты.Вставить("Windows_x86_MSIE");
	Реквизиты.Вставить("Windows_x86_64_MSIE");
	Реквизиты.Вставить("Windows_x86_Chrome");
	Реквизиты.Вставить("Linux_x86_Chrome");
	Реквизиты.Вставить("Linux_x86_64_Chrome");
	Реквизиты.Вставить("MacOS_x86_64_Safari");
	
	ЗаполнитьЗначенияСвойств(Реквизиты, Объект);
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ПоддерживаемыеКлиенты", Реквизиты);
	
	ОткрытьФорму("ОбщаяФорма.ПоддерживаемыеКлиентскиеПриложения", ПараметрыФормы);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область КлиентскаяЛогика

// Строит диалог загрузки компоненты из файла.
&НаКлиенте
Процедура ЗагрузитьКомпонентуИзФайла()
	
	Оповещение = Новый ОписаниеОповещения("ЗагрузитьКомпонентуПослеПредупрежденияБезопасности", ЭтотОбъект);
	ПараметрыФормы = Новый Структура("Ключ", "ПередДобавлениемВнешнейКомпоненты");
	ОткрытьФорму("ОбщаяФорма.ПредупреждениеБезопасности", ПараметрыФормы,,,,, Оповещение);
	
КонецПроцедуры

// Продолжение процедуры ЗагрузитьКомпонентуИзФайла.
&НаКлиенте
Процедура ЗагрузитьКомпонентуПослеПредупрежденияБезопасности(Ответ, Контекст) Экспорт
	
	// Ответ: 
	// - "Продолжить" - Загрузить.
	// - КодВозвратаДиалога.Отмена - Отклонить.
	// - Неопределено - Закрыто окно.
	Если Ответ <> "Продолжить" Тогда
		ЗагрузитьКомпонентуПриОтображенииОшибки();
		Возврат;
	КонецЕсли;
	
	Оповещение = Новый ОписаниеОповещения("ЗагрузитьКомпонентуПослеПомещенияФайла", ЭтотОбъект, Контекст);
	
	ПараметрыЗагрузки = ФайловаяСистемаКлиент.ПараметрыЗагрузкиФайла();
	ПараметрыЗагрузки.Диалог.Фильтр = НСтр("ru = 'Внешняя компонента (*.zip)|*.zip|Все файлы(*.*)|*.*'");
	ПараметрыЗагрузки.Диалог.Заголовок = НСтр("ru = 'Выберите файл внешней компоненты'");
	ПараметрыЗагрузки.ИдентификаторФормы = УникальныйИдентификатор;
	
	ФайловаяСистемаКлиент.ЗагрузитьФайл(Оповещение, ПараметрыЗагрузки, Объект.ИмяФайла);
	
КонецПроцедуры

// Продолжение процедуры ЗагрузитьКомпонентуИзФайла.
&НаКлиенте
Процедура ЗагрузитьКомпонентуПослеПомещенияФайла(ПомещенныйФайл, Контекст) Экспорт
	
	Если ПомещенныйФайл = Неопределено Тогда
		ЗагрузитьКомпонентуПриОтображенииОшибки(НСтр("ru = 'Файл не удалось загрузить на сервер.'"));
		Возврат;
	КонецЕсли;
	
	ПараметрыЗагрузки = Новый Структура;
	ПараметрыЗагрузки.Вставить("АдресХранилищаФайла", ПомещенныйФайл.Хранение);
	ПараметрыЗагрузки.Вставить("ИмяФайла",            ТолькоИмяФайла(ПомещенныйФайл.Имя));
	
	Результат = ЗагрузитьКомпонентуИзФайлаНаСервере(ПараметрыЗагрузки);
	Если Результат.Загружена И ЭтоАдресВременногоХранилища(АдресДвоичныхДанныхКомпоненты)Тогда
		ДополнительнаяИнформация = Результат.ДополнительнаяИнформация;
	Иначе 
		ЗагрузитьКомпонентуПриОтображенииОшибки(Результат.ОписаниеОшибки);
	КонецЕсли;
	
КонецПроцедуры

// Продолжение процедуры ЗагрузитьКомпонентуИзФайла.
&НаКлиенте
Процедура ЗагрузитьКомпонентуПриОтображенииОшибки(ОписаниеОшибки = "")
	
	Если ПустаяСтрока(ОписаниеОшибки) Тогда 
		ЗагрузитьКомпонентуПослеОтображенияОшибки(Неопределено);
	Иначе 
		Оповещение = Новый ОписаниеОповещения("ЗагрузитьКомпонентуПослеОтображенияОшибки", ЭтотОбъект);
		
		СтрокаСПредупреждением = Новый ФорматированнаяСтрока(
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = '%1
				           |Необходимо указать zip-архив с внешней компонентой.
				           |Подробнее:'"),
				ОписаниеОшибки),
			Новый ФорматированнаяСтрока("https://its.1c.ru/db/metod8dev/content/3221",,,, 
				"https://its.1c.ru/db/metod8dev/content/3221"), ".");
			
		ПоказатьПредупреждение(Оповещение, СтрокаСПредупреждением);
	КонецЕсли;
	
КонецПроцедуры

// Продолжение процедуры ЗагрузитьКомпонентуИзФайла.
&НаКлиенте
Процедура ЗагрузитьКомпонентуПослеОтображенияОшибки(ДополнительныеПараметры) Экспорт
	
	// Открыта через программный интерфейс.
	Если Параметры.ПоказатьДиалогЗагрузкиИзФайлаПриОткрытии Тогда 
		Закрыть();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗакрытияВопросаЗаписатьОбъект(РезультатВопроса, Контекст) Экспорт 
	
	Если РезультатВопроса = КодВозвратаДиалога.Да Тогда 
		Записать();
		НачатьОбновлениеКомпонентыСПортала();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура НачатьОбновлениеКомпонентыСПортала()
	
	ЭтоНовый = Объект.Ссылка.Пустая();
	Если ЭтоНовый Тогда 
		Возврат;
	КонецЕсли;
	
	МассивСсылок = Новый Массив;
	МассивСсылок.Добавить(Объект.Ссылка);
	
	Оповещение = Новый ОписаниеОповещения("ПослеОбновленияКомпонентыСПортала", ЭтотОбъект);
	
	ВнешниеКомпонентыСлужебныйКлиент.ОбновитьКомпонентыСПортала(Оповещение, МассивСсылок);
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеОбновленияКомпонентыСПортала(Результат, ДополнительныеПараметры) Экспорт
	
	ОбновитьКарточкуПослеОбновленияКомпонентыСПортала();
	
КонецПроцедуры

#КонецОбласти

#Область СервернаяЛогика

// Серверная логика процедуры ЗагрузитьКомпонентуИзФайла.
&НаСервере
Функция ЗагрузитьКомпонентуИзФайлаНаСервере(ПараметрыЗагрузки)
	
	Если Не Пользователи.ЭтоПолноправныйПользователь(,, Ложь) Тогда
		ВызватьИсключение НСтр("ru = 'Недостаточно прав для совершения операции.'");
	КонецЕсли;
	
	ОбъектСправочника = РеквизитФормыВЗначение("Объект");
	
	Информация = ВнешниеКомпонентыСлужебный.ИнформацияОКомпонентеИзФайла(ПараметрыЗагрузки.АдресХранилищаФайла,, 
		Параметры.ПараметрыПоискаДополнительнойИнформации);
	
	Результат = РезультатЗагрузкиКомпоненты();
	
	Если Не Информация.Разобрано Тогда 
		Результат.ОписаниеОшибки = Информация.ОписаниеОшибки;
		Возврат Результат;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ОбъектСправочника.Идентификатор)
		И ЗначениеЗаполнено(Информация.Реквизиты.Идентификатор) Тогда 
		
		Если ОбъектСправочника.Идентификатор <> Информация.Реквизиты.Идентификатор Тогда 
			Результат.ОписаниеОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru='Текущий идентификатор %1 отличается от загружаемого %2
				         |Обновление невозможно.'"),
				ОбъектСправочника.Идентификатор,
				Информация.Реквизиты.Идентификатор);
			Возврат Результат;
		КонецЕсли;
		
	КонецЕсли;
	
	ЗаполнитьЗначенияСвойств(ОбъектСправочника, Информация.Реквизиты,, "Идентификатор"); // По данным манифеста.
	Если Не ЗначениеЗаполнено(ОбъектСправочника.Идентификатор) Тогда 
		ОбъектСправочника.Идентификатор = Информация.Реквизиты.Идентификатор;
	КонецЕсли;
	ОбъектСправочника.ИмяФайла =  ПараметрыЗагрузки.ИмяФайла;          // Установка имени файла.
	АдресДвоичныхДанныхКомпоненты = ПоместитьВоВременноеХранилище(Информация.ДвоичныеДанные,
		УникальныйИдентификатор);
	
	ОбъектСправочника.ОписаниеОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Загружена из файла %1. %2.'"),
		ОбъектСправочника.ИмяФайла,
		ТекущаяДатаСеанса());
	
	ЗначениеВРеквизитФормы(ОбъектСправочника, "Объект");
	
	Модифицированность = Истина;
	УстановитьВидимостьДоступность();
	
	Результат.Загружена = Истина;
	Результат.ДополнительнаяИнформация = Информация.ДополнительнаяИнформация;
	Возврат Результат;
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция РезультатЗагрузкиКомпоненты()
	
	Результат = Новый Структура;
	Результат.Вставить("Загружена", Ложь);
	Результат.Вставить("ОписаниеОшибки", "");
	Результат.Вставить("ДополнительнаяИнформация", Новый Соответствие);
	
	Возврат Результат;
	
КонецФункции

// Серверная логика обновления компоненты с сайта.
&НаСервере
Процедура ОбновитьКарточкуПослеОбновленияКомпонентыСПортала()
	
	ЭтотОбъект.Прочитать();
	Модифицированность = Ложь;
	УстановитьВидимостьДоступность();
	
КонецПроцедуры

#КонецОбласти

#Область Представление

&НаСервере
Процедура УстановитьВидимостьДоступность()
	
	СправочникОбъект = РеквизитФормыВЗначение("Объект");
	ЭтоНовый = Объект.Ссылка.Пустая();
	
	Элементы.Информация.Видимость = Не ЭтоНовый И ЗначениеЗаполнено(Объект.ОписаниеОшибки);
	
	// Параметры отображения предупреждений при редактировании
	ОтображатьПредупреждение = ОтображениеПредупрежденияПриРедактировании.Отображать;
	НеОтображатьПредупреждение = ОтображениеПредупрежденияПриРедактировании.НеОтображать;
	Если ЗначениеЗаполнено(Объект.Наименование) Тогда
		Элементы.Наименование.ОтображениеПредупрежденияПриРедактировании = ОтображатьПредупреждение;
	Иначе
		Элементы.Наименование.ОтображениеПредупрежденияПриРедактировании = НеОтображатьПредупреждение;
	КонецЕсли;
	Если ЗначениеЗаполнено(Объект.Идентификатор) Тогда 
		Элементы.Идентификатор.ОтображениеПредупрежденияПриРедактировании = ОтображатьПредупреждение;
	Иначе 
		Элементы.Идентификатор.ОтображениеПредупрежденияПриРедактировании = НеОтображатьПредупреждение;
	КонецЕсли;
	Если ЗначениеЗаполнено(Объект.Версия) Тогда 
		Элементы.Версия.ОтображениеПредупрежденияПриРедактировании = ОтображатьПредупреждение;
	Иначе 
		Элементы.Версия.ОтображениеПредупрежденияПриРедактировании = НеОтображатьПредупреждение;
	КонецЕсли;
	
	// Доступность кнопки Сохранить в файл
	Элементы.ФормаСохранитьКак.Доступность = Не ЭтоНовый;
	
	// Зависимость использования и автоматического обновления.
	КомпонентаОтключена = (Объект.Использование = Перечисления.ВариантыИспользованияВнешнихКомпонент.Отключена);
	Элементы.ОбновлятьСПортала1СИТС.Доступность = Не КомпонентаОтключена И СправочникОбъект.ЭтоКомпонентаПоследнейВерсии();
	
	Элементы.ОбновитьСПортала1СИТС.Доступность = Объект.ОбновлятьСПортала1СИТС;
	
КонецПроцедуры

#КонецОбласти

#Область Прочее

&НаКлиенте
Функция ТолькоИмяФайла(ВыбранноеИмяФайла)
	
	// Использовать критично на клиенте, т.к. ПолучитьРазделительПути() на сервере может быть другим.
	МассивПодстрок = СтрРазделить(ВыбранноеИмяФайла, ПолучитьРазделительПути(), Ложь);
	Возврат МассивПодстрок.Получить(МассивПодстрок.ВГраница());
	
КонецФункции

#КонецОбласти

#КонецОбласти