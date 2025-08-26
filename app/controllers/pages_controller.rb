class PagesController < ActionController::Base
  def home
    render inline: <<-ERB
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="UTF-8">
        <title>Конвертер SVG в PDF</title>
        <p style="font-size: 0.85em; color: #555; background: #fff3cd; padding: 10px 15px; border-radius: 8px; border: 1px solid #ffeeba; text-align: center; margin-bottom: 20px;">
        <strong>Предупреждение:</strong> загруженные файлы открыты для всех пользователей. Сервис не требует входа или регистрации.
        </p>
      <style>
        /* Базовые стили */
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: Arial, sans-serif; }
        body { display: flex; flex-direction: column; justify-content: center; align-items: center; height: 100vh; background: #f5f7fa; }
        h1 { margin-bottom: 20px; color: #333; }
        form { background: #fff; padding: 30px 40px; border-radius: 12px; box-shadow: 0 8px 20px rgba(0,0,0,0.1); display: flex; flex-direction: column; gap: 15px; width: 320px; }
        input[type="file"] { padding: 8px; border-radius: 6px; border: 1px solid #ccc; cursor: pointer; }
        button { background-color: #4a90e2; color: white; border: none; padding: 12px; border-radius: 8px; cursor: pointer; font-size: 16px; transition: background 0.3s; }
        button:hover { background-color: #357ABD; }
        #message { margin-top: 15px; text-align: center; color: #d9534f; }

        /* Модальное окно */
        #modal {
          display: none;
          position: fixed;
          top: 0; left: 0; right: 0; bottom: 0;
          background: rgba(0,0,0,0.5);
          justify-content: center;
          align-items: center;
        }
        #modalContent {
          background: #fff;
          padding: 20px 30px;
          border-radius: 12px;
          text-align: center;
          min-width: 300px;
        }
        #modalContent button {
          margin: 10px;
        }
      </style>
      </head>

      <body>
        <h1>Конвертер SVG в PDF</h1>
        <form id="uploadForm" enctype="multipart/form-data">
          <input type="file" name="file" required>
          <button type="submit">Конвертировать</button>
        </form>

        <p id="message"></p>

        <!-- Модальное окно -->
        <div id="modal">
          <div id="modalContent">
            <p>Файл готов! Что вы хотите сделать?</p>
            <button id="viewBtn">Просмотреть</button>
            <button id="downloadBtn">Скачать</button>
            <button id="continueBtn">Продолжить</button>
          </div>
        </div>

        <script>
          const form = document.getElementById('uploadForm');
          const message = document.getElementById('message');
          const modal = document.getElementById('modal');
          const viewBtn = document.getElementById('viewBtn');
          const downloadBtn = document.getElementById('downloadBtn');
          const continueBtn = document.getElementById('continueBtn');

          let pdfUrl = '';

          form.addEventListener('submit', async (e) => {
            e.preventDefault();
            message.textContent = "Загрузка и конвертация...";
            const formData = new FormData(form);

            try {
              const response = await fetch('/documents', { method: 'POST', body: formData });
              const data = await response.json();

              if (data.url) {
                pdfUrl = data.url;
                message.textContent = '';
                modal.style.display = 'flex'; // показать модалку
              } else if (data.error) {
                message.textContent = "Ошибка: " + data.error;
              }
            } catch (err) {
              message.textContent = "Ошибка сети или сервера";
            }
          });

          // Кнопки модалки
          viewBtn.addEventListener('click', () => {
            window.open(pdfUrl, '_blank'); // открыть PDF в новой вкладке
            modal.style.display = 'none';
          });

          downloadBtn.addEventListener('click', async () => {
          try {
            const downloadUrl = pdfUrl.replace(/^https:/, 'http:');
            const response = await fetch(downloadUrl);
            const blob = await response.blob();
            const link = document.createElement('a');
            link.href = URL.createObjectURL(blob);
            link.download = pdfUrl.split('/').pop(); // имя файла из URL
            document.body.appendChild(link);
            link.click();
            link.remove();
          } catch (err) {
            alert("Не удалось скачать файл: " + err.message);
          } finally {
            modal.style.display = 'none';
          }
          });

          continueBtn.addEventListener('click', () => {
            modal.style.display = 'none'; // просто закрыть модалку
          });
        </script>
      </body>
    </html>
    ERB
  end
end
