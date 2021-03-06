#Использовать strings
#Использовать cmdline
#Использовать logos

Перем Соединение;

Перем УникальныеПользователи;
Перем УникальныеРепо;

Перем РепозиторииBSL;
Перем РепозиторииOS;

Перем ЖурналРаботы;
Перем мВозможныеКоманды;

Перем КодВозврата;

Перем РежимВывода;
Перем ФайлВыводаMarkdown;

Функция Инициализировать()

	Соединение = Новый HTTPСоединение("https://github.com");
	
	УникальныеПользователи = Новый Соответствие;
	УникальныеРепо = Новый Соответствие;
	
	РепозиторииOS = Новый Соответствие;
	РепозиторииBSL = Новый Соответствие;

	ЖурналРаботы = Логирование.ПолучитьЛог("oscript.app.bsl-os-github-search");
	
КонецФункции

Функция ОбработатьПараметрыЗапуска()
	
	Попытка
	
		Парсер = Новый ПарсерАргументовКоманднойСтроки();
		
		ДобавитьОписаниеКомандыПомощь(Парсер);
		ДобавитьОписаниеКомандыТекстовыйРезультат(Парсер);
		ДобавитьОписаниеКомандыMarkdown(Парсер);
		
		Аргументы = Парсер.РазобратьКоманду(АргументыКоманднойСтроки);
		ЖурналРаботы.Отладка("ТипЗнч(Аргументы)= "+ТипЗнч(Аргументы));
		
		Если Аргументы = Неопределено ИЛИ Аргументы.Команда = ВозможныеКоманды().ВывестиВКонсоль Тогда
			
			КодВозврата = 0;
			ЖурналРаботы.Информация("Установлен режим вывода в консоль (по умолчанию)");
			РежимВывода = "Журнал";
			
			Возврат Истина;
			
		КонецЕсли;
		
		Команда = Аргументы.Команда;
		ЖурналРаботы.Отладка("Передана команда: "+ Команда);
		
		Для Каждого Параметр Из Аргументы.ЗначенияПараметров Цикл
			ЖурналРаботы.Отладка(Параметр.Ключ + " = " + Параметр.Значение);
		КонецЦикла;
		
		Если Команда = ВозможныеКоманды().Помощь Тогда
			
			КодВозврата = 0;
			ВывестиСправку();
			Возврат Ложь;
			
		ИначеЕсли Команда = ВозможныеКоманды().ВывестиВMarkdown Тогда
			
			КодВозврата = 0;
			
			РежимВывода = "ФайлMarkdown";
			ЖурналРаботы.Информация("Установлен режим вывода в MARKDOWN (текстовый документ с разметкой)");
			
			_аргументПуть = Аргументы.ЗначенияПараметров["--markdown-path"];
			
			ФайлВыводаMarkdown = ОбъединитьПути(ТекущийКаталог(), _аргументПуть); 
			
			ЖурналРаботы.Информация("Файл будет сохранен в: " +ФайлВыводаMarkdown);
			
			Возврат Истина;
			
		КонецЕсли;
		
	Исключение
		ЖурналРаботы.Ошибка(ОписаниеОшибки());
		
		КодВозврата = 1;
		
		Возврат Ложь;

	КонецПопытки;
	
	Возврат Истина;
	
КонецФункции // ИмяПроцедуры()

Функция ВозможныеКоманды()
	
	Если мВозможныеКоманды = Неопределено Тогда
		
		мВозможныеКоманды = Новый Структура;
		
		мВозможныеКоманды.Вставить("ВывестиВMarkdown", "generate-markdown");
		мВозможныеКоманды.Вставить("ВывестиВКонсоль", "generate-txt-log");
		мВозможныеКоманды.Вставить("Помощь", "help");
		
	КонецЕсли;
	
	Возврат мВозможныеКоманды;
	
	
КонецФункции

Процедура ДобавитьОписаниеКомандыПомощь(Знач Парсер)
	ОписаниеКоманды = Парсер.ОписаниеКоманды(ВозможныеКоманды().Помощь);
	Парсер.ДобавитьКоманду(ОписаниеКоманды);
КонецПроцедуры

Процедура ДобавитьОписаниеКомандыТекстовыйРезультат(Знач Парсер)
	ОписаниеКоманды = Парсер.ОписаниеКоманды(ВозможныеКоманды().ВывестиВКонсоль);
	Парсер.ДобавитьКоманду(ОписаниеКоманды);
КонецПроцедуры

Процедура ДобавитьОписаниеКомандыMarkdown(Знач Парсер)
	ОписаниеКоманды = Парсер.ОписаниеКоманды(ВозможныеКоманды().ВывестиВMarkdown);
	
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--markdown-path", "путь к сохранению результирующего файла");
	Парсер.ДобавитьКоманду(ОписаниеКоманды);
КонецПроцедуры


Процедура ВывестиСправку()
	
	Сообщить(
	"Утилита поиска BSL (1C) и OS(oscript) файлов в GitHub репозиториях
	|
	|Возможные команды: 
	|	generate-txt-log [] - режим по умолчанию: вывод информации в консоль и журнал работы 
	|  
	|	generate-markdown [--markdown-path] - режим генерации файла с разметкой Mаrkdown
	|		параметр:  --markdown-path - путь к сохранению результирующего файла
	|
	|	help - режимы справки: выводит справку по командам скрипта
	|");
	
	
КонецПроцедуры

Функция ВыполнитьПоиск(СтрокаПоиска, ТекащаяКоллекцияПоиска)

	СсылкаНаСтраницуРезультатов = ПолучитьСсылкуНаСтраницуРезультатов(СтрокаПоиска);

	МассивТаймаутов = Новый Массив;
	МассивТаймаутов.Добавить(2000);
	МассивТаймаутов.Добавить(3000);
	МассивТаймаутов.Добавить(4000);
	СчетчикТаймаутов = 0;

	СчетчикСтраниц = 0;

	Попытка
		Пока Истина Цикл

			ЖурналРаботы.Информация("--> Загружаем и обрабатываем страницу результатов поиска по ссылке: ");
			ЖурналРаботы.Информация(СсылкаНаСтраницуРезультатов);

			СодержимоеСтраницы = ВыполнитьЗапросМетодомGET(СсылкаНаСтраницуРезультатов);
			СтруктураРезультатов = ПолучитьДанныеСтраницыРезультатов(СодержимоеСтраницы);

			Для каждого ЭлементРезультата из СтруктураРезультатов.ЭлементыРезультатаПоиска Цикл

				УникальныеПользователи[ЭлементРезультата.ИмяПользователя] = "https://github.com/" + ЭлементРезультата.ИмяПользователя;
				УникальныеРепо[ЭлементРезультата.ИмяПользователя + "/" + ЭлементРезультата.ИмяРепозитория] = ЭлементРезультата.ИмяПользователя + "/" + ЭлементРезультата.ИмяРепозитория;
				
				ТекащаяКоллекцияПоиска[ЭлементРезультата.ИмяПользователя + "/" + ЭлементРезультата.ИмяРепозитория] = "https://github.com/" + ЭлементРезультата.ИмяПользователя + "/" + ЭлементРезультата.ИмяРепозитория;

			КонецЦикла;

			СсылкаНаСтраницуРезультатов = ПолучитьСсылкуНаСтраницуРезультатов(СтрокаПоиска);

			Если НЕ ПустаяСтрока(СсылкаНаСтраницуРезультатов) Тогда
				СчетчикСтраниц = СчетчикСтраниц + 1;
				Если СчетчикСтраниц % 8 = 0 Тогда
					ЖурналРаботы.Информация("Ждем 10 секунд...");
					Приостановить(10000);
				КонецЕсли;

				Если СчетчикТаймаутов > 2 Тогда
					СчетчикТаймаутов = 0;
				КонецЕсли;
				Приостановить(МассивТаймаутов[СчетчикТаймаутов]);
				СчетчикТаймаутов = СчетчикТаймаутов + 1;
			Иначе
				ЖурналРаботы.Информация("Получены все результаты поиска!");
				Прервать;
			КонецЕсли;

		КонецЦикла;

	Исключение 
		ЖурналРаботы.Информация(ОписаниеОшибки());
	КонецПопытки;

КонецФункции

Функция ПолучитьДанныеСтраницыРезультатов(HtmlКодСтраницы)

	ЭлементыСтраницы = СтроковыеФункции.РазложитьСтрокуВМассивПодстрок(HtmlКодСтраницы, "class=""code-list-item");

	// Структура страницы: 
	// ... тут шапка страницы ...
	// <div id="code_search_results"> 
	// 		<div class="code-list">
	//			<div class="code-list-item code-list-item-public ">
	//				... тут содержимое элемента результатов поиска ...
	//			</div>
	//		</div>
	//		<div class="paginate-container">
	// 		... ссылки пагинации ...
	//		</div>
	// </div>
	// ...
	// Нас интересуют все элементы, начиная с первого (т.к. первый - это шапка страницы результатов поиска).

	// Отрезаем "шапку":
	ЧастиСтроки = СтроковыеФункции.РазложитьСтрокуВМассивПодстрок(HtmlКодСтраницы, "<div class=""code-list"">");
	ЧастиСтроки = СтроковыеФункции.РазложитьСтрокуВМассивПодстрок(ЧастиСтроки[1], "<div class=""paginate-container"">");
	// Теперь первый элемент содержит код элементов результата поиска, а второй - подвал.

	МассивРазобранныхЭлементыРезультата = Новый Массив;
	МассивЭлементовРезультата = СтроковыеФункции.РазложитьСтрокуВМассивПодстрок(ЧастиСтроки[0], "<div class=""code-list-item");
	Для каждого HtmlКодЭлемента из МассивЭлементовРезультата Цикл
		МассивРазобранныхЭлементыРезультата.Добавить(ПолучитьДанныеРезультатаПоиска(HtmlКодЭлемента));
	КонецЦикла;

	Возврат Новый Структура("ЭлементыРезультатаПоиска", 
		МассивРазобранныхЭлементыРезультата
	);

КонецФункции

Функция ПолучитьДанныеРезультатаПоиска(HtmlКодЭлементаРезультата)

	//<div class="code-list-item code-list-item-public ">
	//    <a href="/unitpoint"><img alt="@unitpoint" class="avatar" height="28" src="https://avatars1.githubusercontent.com/u/1647314?v=3&amp;s=56" width="28"></a>
	//  <p class="title">
	//      <a href="/unitpoint/os2d-bin-win">unitpoint/os2d-bin-win</a>
	//       –
	//      <a href="/unitpoint/os2d-bin-win/blob/368444cb0930aac82dc8eb96b9f02fe5c97ab8e0/Demo/data/os2d/dump.os" title="Demo/data/os2d/dump.os">dump.os</a> <br>
	//      <span class="text-small text-muted match-count">Showing the top two matches.</span>
	//    <span class="text-small text-muted updated-at">Last indexed <relative-time datetime="2016-03-25T00:26:27Z" title="25 марта 2016 г., 3:26 GMT+3">on 25 Mar</relative-time>.</span>
	//  </p>
	//    <div class="file-box blob-wrapper">
	//      <table class="highlight">
	//      	... сниппет с фрагментом кода ...
	//      </table>
	//    </div>
	//</div>

	ПозНачалаИмениПользователя = СтрНайти(HtmlКодЭлементаРезультата, "<img alt=""@");
	ПозОкончанияИмениПользователя = СтрНайти(HtmlКодЭлементаРезультата, """ class=""avatar""");
	ИмяПользователя = Сред(HtmlКодЭлементаРезультата, ПозНачалаИмениПользователя + 11, ПозОкончанияИмениПользователя - ПозНачалаИмениПользователя - 11);
	//ЖурналРаботы.Информация("Имя пользователя: " + ИмяПользователя);

	ПозНачалаИмениРепо = СтрНайти(HtmlКодЭлементаРезультата, "<a href=""/" + ИмяПользователя + "/");
	ПозОкончанияИмениРепо = СтрНайти(HtmlКодЭлементаРезультата, """>" + ИмяПользователя + "/");
	ИмяРепозитория = Сред(HtmlКодЭлементаРезультата, 
		ПозНачалаИмениРепо + 10 + СтрДлина(ИмяПользователя) + 1, 
		ПозОкончанияИмениРепо - ПозНачалаИмениРепо - 10 - СтрДлина(ИмяПользователя) - 1
	);

	//ЖурналРаботы.Информация("Имя репозитория: " + ИмяРепозитория);

	Возврат Новый Структура("ИмяПользователя,ИмяРепозитория",
		ИмяПользователя,
		ИмяРепозитория
	);

КонецФункции

Функция ВыполнитьЗапросМетодомGET(Ресурс, ПараметрыЗапроса=Неопределено, ВремяОжиданияВМинутах=2)

	Заголовки = Новый Соответствие();
	Заголовки.Вставить("Accept", "text/html");
	Заголовки.Вставить("Content-Type", "text/html");

	Запрос = Новый HTTPЗапрос(Ресурс, Заголовки);

	Ответ = Соединение.Получить(Запрос);

	Если Ответ.КодСостояния = 429 Тогда
		ЖурналРаботы.Информация("Github жалуется, что мы слишком часто делаем запросы - подождем " + ВремяОжиданияВМинутах + " минут и попытаемся снова");
		Приостановить(ВремяОжиданияВМинутах * 60 * 1000);
		Возврат ВыполнитьЗапросМетодомGET(Ресурс, ПараметрыЗапроса, ВремяОжиданияВМинутах + 1); // Увеличим время ожидания
	ИначеЕсли Ответ.КодСостояния <> 200 Тогда
		ВызватьИсключение "GitHub сообщил об ошибке " + Ответ.КодСостояния  + ": " + Ответ.ПолучитьТелоКакСтроку();
	КонецЕсли;

	Возврат Ответ.ПолучитьТелоКакСтроку();

КонецФункции

Функция ПолучитьСсылкуНаСтраницуРезультатов(Знач СтрокаПоиска)
	
	СсылкаНаСтраницуРезультатов = "search?utf8=%E2%9C%93&type=Code&ref=searchresults&q=" + КодироватьСтроку(СтрокаПоиска, СпособКодированияСтроки.КодировкаURL);
	Для Каждого УникальныйРепо Из УникальныеРепо Цикл
		СсылкаНаСтраницуРезультатов = СсылкаНаСтраницуРезультатов + "+" + КодироватьСтроку("-repo:" + УникальныйРепо.Значение, СпособКодированияСтроки.КодировкаURL);
	КонецЦикла;
	Возврат СсылкаНаСтраницуРезультатов;
	
КонецФункции

Процедура ВывестиРезультатыПоиска()
	
	ЖурналРаботы.Информация("=========================================================================");
	ЖурналРаботы.Информация("============================== ПОЛЬЗОВАТЕЛИ =============================");
	ЖурналРаботы.Информация("=========================================================================");
	Для каждого Элемент из УникальныеПользователи Цикл
		ЖурналРаботы.Информация(Элемент.Ключ);
	КонецЦикла;

	ЖурналРаботы.Информация("=========================================================================");
	ЖурналРаботы.Информация("============================== РЕПОЗИТОРИИ ==============================");
	ЖурналРаботы.Информация("=========================================================================");
	Для каждого Элемент из УникальныеРепо Цикл
		ЖурналРаботы.Информация(Элемент.Значение);
	КонецЦикла;

КонецПроцедуры

Процедура ВывестиРезультатыПоискаВMarkdown()
	
	ДокументMarkdown = Новый ЗаписьТекста;
	
	Попытка
		ДокументMarkdown.Открыть(ФайлВыводаMarkdown);
	Исключение
		ЖурналРаботы.Ошибка("Ошибка открытия документа для записи результатов 
		|" + ФайлВыводаMarkdown + "
		|подробное описание ошибки: " + ОписаниеОшибки());
	КонецПопытки;
	
	ЖурналРаботы.Информация("начато формирование файла результатов " + ФайлВыводаMarkdown);
	
	ДокументMarkdown.ЗаписатьСтроку(
	"# BSL и OScript репозиторий и их пользователи
	|
	|Актуальность: " + ТекущаяДата() + "
	|
	|## Пользователи
	|
	|Общее количество пользователей: " + УникальныеПользователи.Количество() + "
	|Всего репозиториев: " + УникальныеРепо.Количество() + "
	|
	|| Пользователь | Акаунт |
	|---|---|
	|" + СоответствиеВMarkdownТаблицу(УникальныеПользователи) + "
	|
	|
	|## Репозитории BSL (1C)
	|
	|Общее количество репозиториев: " + РепозиторииBSL.Количество() + "
	|
	|| Репозиторий | URL |
	||---|---|
	|" + СоответствиеВMarkdownТаблицу(РепозиторииBSL) + "
	|
	|
	|## Репозитории OS (1Script)
	|
	|Общее количество репозиториев: " + РепозиторииOS.Количество() + "
	|
	|| Репозиторий | URL |
	||---|---|
	|" + СоответствиеВMarkdownТаблицу(РепозиторииOS) + "
	|
	|
	|");
	
	ДокументMarkdown.Закрыть();

КонецПроцедуры

Функция СоответствиеВMarkdownТаблицу(_соответствие)
	
	СтроковоеПредставлениеСоответствия = "";
	
	Для каждого ключЗначение Из _соответствие Цикл
		СтроковоеПредставлениеСоответствия = СтроковоеПредставлениеСоответствия + "| " + 
			ключЗначение.Ключ + " | " + ключЗначение.Значение + " |
			|";
	КонецЦикла;
	
	Возврат СтроковоеПредставлениеСоответствия;
	
КонецФункции

Инициализировать();

УспешноОбработалиПараметры = ОбработатьПараметрыЗапуска();

Если УспешноОбработалиПараметры Тогда
	
	ВыполнитьПоиск("КонецПроцедуры OR КонецФункции OR КонецЦикла OR КонецЕсли OR EndProcedure OR EndFunction in:file extension:os"
		, РепозиторииOS);
	ВыполнитьПоиск("КонецПроцедуры OR КонецФункции OR КонецЦикла OR КонецЕсли OR EndProcedure OR EndFunction in:file extension:bsl"
		, РепозиторииBSL);

	Если РежимВывода = "ФайлMarkdown" Тогда
		ВывестиРезультатыПоискаВMarkdown();
	Иначе
		ВывестиРезультатыПоиска();	
	КонецЕсли;

Иначе
	ЗавершитьРаботу(КодВозврата);
КонецЕсли; 
