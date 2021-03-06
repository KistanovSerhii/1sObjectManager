
#Область ОписаниеПеременных
#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ЭтаФорма.ИмяОбъектаНаполнения 			= "Справочники";
	ЭтаФорма.поНаименованиюЕслиКодНеНайден 	= Истина;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы
#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыИмяТаблицыФормы
#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Заполнить(Команда)

	имяМенеджер = ЭтаФорма.ИмяОбъектаНаполнения;
	имяОбъект	= Объект.ОбъектИмя;
	
	Если НЕ ЗначениеЗаполнено(имяМенеджер) ИЛИ НЕ ЗначениеЗаполнено(имяОбъект) Тогда
		Сообщить("Заполните на первой странице реквизиты: ""ОбъектМенеджер (Тип)"" и ""Объект Имя""");
		Возврат;
	КонецЕсли;
	
	ОписаниеРеквизитов = ПолучитьМетаданныеНаСервере(имяМенеджер, имяОбъект);
	Если ОписаниеРеквизитов = Неопределено Тогда
		Сообщить("Неудалось получить метаданные для " + имяМенеджер + "." + имяОбъект);
		Возврат;
	КонецЕсли;
	
	ЭтаФорма.Метаданные.Очистить();
	
	Для Каждого реквизит Из ОписаниеРеквизитов Цикл
		новаяСтр = ЭтаФорма.Метаданные.Добавить();
		ЗаполнитьЗначенияСвойств(новаяСтр, реквизит);
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ГенерироватьЗаголовок(Команда)
	
	ЗаголовокМакета = Новый Массив;
	ЭтоНеСсылка		= Новый Соответствие;
	
	ЭтоНеСсылка.Вставить("Строка", 	Истина);
	ЭтоНеСсылка.Вставить("Число", 	Истина);
	ЭтоНеСсылка.Вставить("Булево", 	Истина);
	
	Для Каждого стрТЧ Из ЭтаФорма.Метаданные Цикл
		Если НЕ стрТЧ.Использовать Тогда
			Продолжить;
		КонецЕсли;
		
		ДобавитьУказатель = ЭтоНеСсылка.Получить(стрТЧ.Тип) <> Истина;
		
		стрЗаголовок = стрТЧ.Имя + ?(ДобавитьУказатель, "_ref_" + СтрТЧ.Тип, "");
		ЗаголовокМакета.Добавить(стрЗаголовок);
	КонецЦикла;

	Сообщить(СтрСоединить(ЗаголовокМакета, ";"));
	
КонецПроцедуры

&НаКлиенте
Процедура Создать(Команда)
	Если НЕ ЗначениеЗаполнено(Объект.ОбъектИмя) Тогда
		Сообщить("Укажите объект который необходимо наполнить");
		Возврат;
	КонецЕсли;	
	
	Лог = СоздатьНаСервере();
	Для Каждого Ошибка Из Лог.Ошибки Цикл
		Сообщить(
		"НумерацияСвязи: " 			+ Ошибка.НумерацияСвязи
		+ " , элемент: "    		+ Ошибка.Элемент
		+ " , поле: " 				+ Ошибка.Поле
		+ " , ошибка заполнения: "	+ Ошибка.Текст);
	КонецЦикла;
	
	Если Лог.Ошибки.Количество() = 0 Тогда
		Сообщить("Все поля успешно заполнены, лог ошибок пуст!");		
	КонецЕсли;
	
	Если Лог.Данные.Количество() Тогда
		ПоказатьЛогДобавленияДанных(Лог.Данные);
	КонецЕсли;
	
	Сообщить(Объект.ОбъектИмя);
	Объект.ОбъектИмя = "";
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область ДанныеТабличногоДокументаВРезультатЗапроса

&НаСервере
Функция ПреобразоватьТабличныйДокументВТаблицуЗначений(ТабДокумент)
	
	ПоследняяСтрока = ТабДокумент.ВысотаТаблицы;
	ПоследняяКолонка = ТабДокумент.ШиринаТаблицы;
	ОбластьЯчеек = ТабДокумент.Область(1, 1, ПоследняяСтрока, ПоследняяКолонка); 
	
	// Создаем описание источника данных на основании области ячеек табличного документа.
	ИсточникДанных = Новый ОписаниеИсточникаДанных(ОбластьЯчеек);

	// Создаем объект для интеллектуального построения отчетов,
	// указываем источник данных и выполняем построение отчета.
	ПостроительОтчета = Новый ПостроительОтчета; 
	ПостроительОтчета.ИсточникДанных = ИсточникДанных;
	ПостроительОтчета.Выполнить();
	
	// Результат выгружаем в таблицу значений.
	ТабЗначений = ПостроительОтчета.Результат.Выгрузить();
	
	Возврат ТабЗначений
	
КонецФункции

Функция ТекстЗапроса()
	Возврат
	"ВЫБРАТЬ
	|	ТабДок.*
	|	ПОМЕСТИТЬ ВТТабДок
	|ИЗ
	|	&ДанныеТабДок КАК ТабДок
	|;
	|
	|ВЫБРАТЬ
	|	ВТТабДок.*
	|ИЗ
	|	ВТТабДок КАК ВТТабДок";      
КонецФункции

Функция ПолучитьЗапрос(текстЗапроса, параметрыЗапросаМассивСтруктур)
	Запрос = Новый Запрос;
	Запрос.Текст = текстЗапроса;
	Для Каждого парам Из параметрыЗапросаМассивСтруктур Цикл
		Запрос.УстановитьПараметр(парам.Имя, парам.Знч);
	КонецЦикла;
	
	Возврат Запрос;
КонецФункции

#КонецОбласти

&НаСервере
Функция СоздатьНаСервере()
	
	параметрыЗапросаМассивСтруктур 	= Новый Массив;
	параметрыЗапроса				= новый Структура;
	Лог 		    				= Новый Структура;	
		
	Лог.Вставить("Данные", Новый Массив);
	Лог.Вставить("Ошибки", Новый Массив);
	
	ОшибкаОтсутствияТипа = Новый Структура;
	ОшибкаОтсутствияТипа.Вставить("НумерацияСвязи", "Нет");
	ОшибкаОтсутствияТипа.Вставить("Элемент", 		"ОбъектМенеджер");
	ОшибкаОтсутствияТипа.Вставить("Поле",    		"Тип объекта");
	ОшибкаОтсутствияТипа.Вставить("Текст",   		"Не найден!");
	
	параметрыЗапроса.Вставить("Имя", "ДанныеТабДок");
	параметрыЗапроса.Вставить("Знч", ПреобразоватьТабличныйДокументВТаблицуЗначений(ТабДокумент));
	
	параметрыЗапросаМассивСтруктур.Добавить(параметрыЗапроса);
	
	имяМенеджер 	= ЭтаФорма.ИмяОбъектаНаполнения;	
	доступныеТипы 	= Новый Соответствие;
	
	доступныеТипы.Вставить("Справочники", Справочники);
	доступныеТипы.Вставить("Документы",   Документы);
	
	ОбъектНаполненияМенеджер = доступныеТипы.Получить(имяМенеджер);
	Если ОбъектНаполненияМенеджер = Неопределено Тогда
		Лог.Ошибки.Добавить(ОшибкаОтсутствияТипа);			
		Возврат Лог;
	КонецЕсли;	
	
	ТекстЗапроса		= ТекстЗапроса();
	Запрос				= ПолучитьЗапрос(ТекстЗапроса, параметрыЗапросаМассивСтруктур);
	колонки				= Запрос.Параметры.ДанныеТабДок.Колонки;	
	РезультатЗапроса	= Запрос.Выполнить();
	Выборка				= РезультатЗапроса.Выбрать();
	КолонкиМакета		= ПреобразоватьРезультатЗапросаВСтруктуру(РезультатЗапроса);		
	ИтераторА			= 0;
	
	Пока Выборка.Следующий() Цикл
		
		ИтераторА = ИтераторА + 1;
		
		ОбъектНаполнения = ОбъектНаполненияМенеджер[Объект.ОбъектИмя];
		Если Тип(ОбъектНаполненияМенеджер) = Тип(Справочники) Тогда
			обк = ОбъектНаполнения.СоздатьЭлемент();
		ИначеЕсли Тип(ОбъектНаполненияМенеджер) = Тип(Документы) Тогда
			обк = ОбъектНаполнения.СоздатьДокумент();
		Иначе				
			Лог.Ошибки.Добавить(ОшибкаОтсутствияТипа);
			
			Возврат Лог;
		КонецЕсли;
			
		Для Каждого поле Из колонки Цикл
			
			// Зарезервированное обработкой имя колонки, для связи входных и выходных данных
			Если поле.Имя = "НумерацияСвязи" Тогда
				Продолжить;
			КонецЕсли;
			
			// мСоставПоля[0] - значение реквизита
			// мСоставПоля[1] - Тип ссылочного объекта (имя метаданных, например "Номенклатура")
			мСоставПоля = СтрРазделить(поле.Имя, "_ref_", ЛОЖЬ);			
			
			Если мСоставПоля.Количество() = 1 Тогда
				обк[поле.Имя] = Выборка[поле.Имя];
			ИначеЕсли мСоставПоля.Количество() = 2 Тогда
				ссылкаНаОбк = Справочники[ мСоставПоля[1] ].НайтиПоКоду( Выборка[поле.Имя] );
				
				ссылкаНаОбк = ?(ссылкаНаОбк = Неопределено И поНаименованиюЕслиКодНеНайден,
								Справочники[ мСоставПоля[1] ].НайтиПоНаименованию( Выборка[поле.Имя] ),
								ссылкаНаОбк);			
							
				Если ссылкаНаОбк = Неопределено Тогда
					Ошибка = Новый Структура;
					Ошибка.Вставить("НумерацияСвязи", 	Выборка["НумерацияСвязи"]);
					Ошибка.Вставить("Элемент", 			мСоставПоля[1]);
					Ошибка.Вставить("Поле",    			поле.Имя);
					Ошибка.Вставить("Текст",   			"Не найден!");
					
					Лог.Ошибки.Добавить(Ошибка);
					Продолжить;
				КонецЕсли;
				
				обк[ мСоставПоля[0] ] = ?(ТипЗнч(ссылкаНаОбк) = Тип("Массив"), ссылкаНаОбк[0], ссылкаНаОбк);
			КонецЕсли;
			
		КонецЦикла;
		
		обк.УстановитьНовыйКод();
		
		Попытка		
			обк.Записать();
			
    		КопияСтруктуры = Новый Структура;
			
			Для Каждого ЭлементСтруктуры Из КолонкиМакета Цикл
    		  КопияСтруктуры.Вставить(ЭлементСтруктуры.Ключ, ЭлементСтруктуры.Значение);
		  	КонецЦикла;
		  
			ЗаполнитьЗначенияСвойств(КопияСтруктуры, обк);			
			
			Если Тип(ОбъектНаполненияМенеджер) = Тип(Справочники) Тогда
				КопияСтруктуры.Вставить("Код", 			обк.Код);
				КопияСтруктуры.Вставить("Наименование", обк.Наименование);
			ИначеЕсли Тип(ОбъектНаполненияМенеджер) = Тип(Документы) Тогда
				КопияСтруктуры.Вставить("Дата",			обк.Дата);
				КопияСтруктуры.Вставить("Номер",		обк.Номер);			
			КонецЕсли;
			
			КопияСтруктуры.Вставить("НумерацияСвязи", Число(Выборка["НумерацияСвязи"]));
			КопияСтруктуры.Вставить("СсылкаКакСтрока", XMLСтрока(обк.Ссылка));
			
			Лог.Данные.Добавить(КопияСтруктуры);			
		Исключение
			Ошибка = Новый Структура;
			Ошибка.Вставить("НумерацияСвязи",	Выборка["НумерацияСвязи"]);
			Ошибка.Вставить("Элемент", 			?(мСоставПоля.Количество() = 2, мСоставПоля[1], мСоставПоля[0]) );
			Ошибка.Вставить("Поле",    			поле.Имя);
			Ошибка.Вставить("Текст",   			ОписаниеОшибки());
			
			Лог.Ошибки.Добавить(Ошибка);
		КонецПопытки;
		
	КонецЦикла;

	Возврат Лог;
	
КонецФункции

// Возвращает данные первой записи результата запроса в виде структуры.
// 
// Параметры:
//  РезультатЗапроса - РезультатЗапроса - Результат запроса, содержащий данные для обработки.
// 
// Возвращаемое значение:
//  Структура - структура с результатом.
//
&НаСервере
Функция ПреобразоватьРезультатЗапросаВСтруктуру(Знач РезультатЗапроса)
	
	Результат = Новый Структура;
	Для Каждого Колонка Из РезультатЗапроса.Колонки Цикл
		мИмяРеквизита = СтрРазделить(Колонка.Имя, "_ref_", ЛОЖЬ);
		Результат.Вставить(мИмяРеквизита[0]);
	КонецЦикла;
	
	Если РезультатЗапроса.Пустой() Тогда
		Возврат Результат;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Функция - Преобразовать массив структур в таблицу значений
//
// Параметры:
//  мсДанные - Массив Из Структура 
// 
// Возвращаемое значение:
//  тзДанные - ТаблицаЗначений
//
&НаСервере
Функция ПреобразоватьМассивСтруктурВТаблицуЗначений(мсДанные)
    
    тзДанные = Новый ТаблицаЗначений;
    Для Каждого ЭлементМассива Из мсДанные Цикл
        Если тзДанные.Колонки.Количество() = 0 Тогда
            Для Каждого ЗначениеСтруктуры Из ЭлементМассива Цикл
				МассивДопустимыеТипы = Новый Массив;
				ТипКолонки = ТипЗнч(ЗначениеСтруктуры.Значение); 
    			МассивДопустимыеТипы.Добавить(ТипКолонки);                     
    			Описание_Типов = Новый ОписаниеТипов(МассивДопустимыеТипы);
				тзДанные.Колонки.Добавить(ЗначениеСтруктуры.Ключ,Описание_Типов);
            КонецЦикла;
        КонецЕсли;
        НоваяСтрока = тзДанные.Добавить();
        Для Каждого ЗначениеСтруктуры Из ЭлементМассива Цикл
            НоваяСтрока[ЗначениеСтруктуры.Ключ] = ЗначениеСтруктуры.Значение;
        КонецЦикла;
    КонецЦикла;
    
    Возврат тзДанные;
    
КонецФункции

#Область ПоказатьРезультат

// Процедура - Показать лог добавления данных
//
// Параметры:
//  Данные	 - Массив Из Структура 
//  *Код			- Строка, соответствующий реквизит элемента справочника
//  *Наименование 	- Строка, соответствующий реквизит элемента справочника
//	*НумерацияСвязи - Строка, номер по порядку для точного понимания о какой записи идет речь
//
&НаСервере
Процедура ПоказатьЛогДобавленияДанных(мсДанные)
	
	Данные 			= ПреобразоватьМассивСтруктурВТаблицуЗначений(мсДанные);
	ТабличныйДок	= ЭтаФорма.ТабДокРезультат;	
	
	ИсточникДанныхВТабличныйДокумент(Данные, ТабличныйДок);
	
КонецПроцедуры

// Вывести результат выполнения запроса в табличный документ.
//
// Рекомендация использовать с:
//   НовыйЗапрос, НовыйПараметры, УстановитьПараметрыЗапрос, ТекстЗапросаПрограммно
//
// Параметры:
//   ИсточникДанных  - Тип: ТаблицаЗначений, РезультатЗапроса, ОбластьЯчеекТабличногоДокумента
//   ТабличныйДокумент - ТабличныйДокумент, в который будет выведен результат запроса.
//
&НаСервереБезКонтекста
Процедура ИсточникДанныхВТабличныйДокумент(ИсточникДанных, ТабличныйДокумент)
	
	Построитель 				= Новый ПостроительОтчета;
    Построитель.ИсточникДанных  = Новый ОписаниеИсточникаДанных(ИсточникДанных);

	ТабличныйДокумент.Очистить();
	Построитель.Вывести(ТабличныйДокумент);

КонецПроцедуры // ИсточникДанныхВТабличныйДокумент()

#КонецОбласти

// Функция - Получить метаданные на сервере
//
// Параметры:
//  имяМенеджер	 - Строка, тип менеджер объекта - пример: Справочники, Документы
//  имяОбъект	 - Строка, тип объекта - пример: Номенклатура, РеализацияТоваровУслуг
// 
// Возвращаемое значение:
//   МетаданныеОбк - Массив ИЗ Структура:
//		*Имя 		- Строка - Имя реквизита
//		*Синоним 	- Строка - Синоним реквизита
//		*Тип 		- Строка - Тип реквизита
//
&НаСервереБезКонтекста
Функция ПолучитьМетаданныеНаСервере(имяМенеджер, имяОбъект)
	
	ОписаниеОбк 	= Новый Массив;
	доступныеТипы 	= Новый Соответствие;
	
	доступныеТипы.Вставить("Справочники", Справочники);
	доступныеТипы.Вставить("Документы",   Документы);
	
	ОбъектНаполненияМенеджер = доступныеТипы.Получить(имяМенеджер);
	Если ОбъектНаполненияМенеджер = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;

	МетаданныеНаполняемогоОбк = Справочники[имяОбъект].ПустаяСсылка().Метаданные();

	СтандартныеРеквизиты = МетаданныеНаполняемогоОбк.СтандартныеРеквизиты;	
	НаполнитьОписаниеМетаданныхНаполняемогоОбк(ОписаниеОбк, СтандартныеРеквизиты);
	
	ДобавленныеРеквизиты = МетаданныеНаполняемогоОбк.Реквизиты;
	НаполнитьОписаниеМетаданныхНаполняемогоОбк(ОписаниеОбк, ДобавленныеРеквизиты);
	
	Возврат ОписаниеОбк;
		
КонецФункции

// Функция - Наполнить описание метаданных наполняемого обк
//
// Параметры:
//  ОписаниеОбк	 - Массив - для наполнения
//  Реквизиты	 - Коллекция реквизитов - полученная из метаданных 
// 
// Возвращаемое значение:
//   - 
//
&НаСервереБезКонтекста
Функция НаполнитьОписаниеМетаданныхНаполняемогоОбк(ОписаниеОбк, Реквизиты)
	
	Для Каждого реквизит Из Реквизиты Цикл
		ОписаниеРеквизита = Новый Структура;
		ОписаниеРеквизита.Вставить("Имя", 		Строка(реквизит.Имя) );
		ОписаниеРеквизита.Вставить("Синоним", 	Строка( ?(НЕ ЗначениеЗаполнено(реквизит.Синоним), реквизит.Имя, реквизит.Синоним) ));
		ОписаниеРеквизита.Вставить("Тип", 		СтрЗаменить( Строка(ТипЗнч(Реквизит.Тип.ПривестиЗначение()) ), " ", "") );
		
		ОписаниеОбк.Добавить(ОписаниеРеквизита);
	КонецЦикла;

	Возврат ОписаниеОбк;
	
КонецФункции

#КонецОбласти