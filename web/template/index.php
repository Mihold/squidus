<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <title><?php echo $template['title'] ?></title>
  </head>
  <body>
    <header>
      <hgroup>
         <h1>Заголовок "h1" из hgroup</h1>
         <h2>Заголовок "h2" из hgroup</h2>
      </hgroup>
    </header>
    <nav>
      <a href=link1.html>Первая ссылка из блока "nav"</a>
      <a href=link2.html>Вторая ссылка из блока "nav"</a>
    </nav>
    <section>
      <article>
        <h1>Заголовок статьи из блока "article"</h1>
        <p>Текст абзаца статьи из блока "article"</p>
          <details>
            <summary>Блок "details", текст тега "summary"</summary>
            <p>Абзац из блока "details"</p>
          </details>
      </article>
    </section>
    <footer>
      <time>Содержимое тега "time" блока "footer"</time>
      <p>Содержимое абзаца из блока "footer"</p>
    </footer>
  </body>
</html>