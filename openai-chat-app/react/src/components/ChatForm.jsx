import { useState } from "react";
import axios from "axios";

const ChatForm = ({ chatHistory, setChatHistory }) => {
  const [formState, setFormState] = useState({
    system_text: "",
    user_text: "",
    api_model: "gpt-3.5-turbo",
  });

  const handleInputChange = (event) => {
    setFormState({
      ...formState,
      [event.target.name]: event.target.value,
    });
  };

  const handleSubmit = (event) => {
    event.preventDefault();

    // ユーザーのメッセージをすぐにチャットの履歴に追加
    setChatHistory([
      ...chatHistory,
      { message: formState.user_text, type: "user" },
    ]);

    // CloudFront ディストリビューションドメイン名
    const url = import.meta.env.VITE_LAMBDA_URL;
    const params = {
      system_text: formState.system_text,
      user_text: formState.user_text,
      api_model: formState.api_model,
    };

    axios
      .get(url, { params })
      .then((response) => {
        console.log(response);
        // システムのメッセージをチャットの履歴に追加
        const sanitizedMessage = response.data.replace(/\n/g, "<br />");
        setChatHistory((prevChatHistory) => [
          ...prevChatHistory,
          { message: sanitizedMessage, type: "system" },
        ]);
      })
      .catch((error) => {
        console.log(url, { params });
        console.error("Error:", error);
      });
  };

  return (
    <form onSubmit={handleSubmit} className="bottom-form">
      <div className="form-wrap">
        <div className="form-area system-form">
          <label style={{ marginRight: "10px" }}>
            AIの役割/性格:
            <textarea
              placeholder="AIの役割とか性格を入力してね。"
              name="system_text"
              value={formState.system_text}
              onChange={handleInputChange}
              className="text-area"
            ></textarea>
          </label>
          <label style={{ marginRight: "10px" }}>
            APIモデル:
            <select
              name="api_model"
              value={formState.api_model}
              onChange={handleInputChange}
            >
              <option value="gpt-3.5-turbo">gpt-3.5-turbo</option>
              <option value="gpt-3.5-turbo-16k">gpt-3.5-turbo-16k</option>
              <option value="gpt-3.5-turbo-0613">gpt-3.5-turbo-0613</option>
              <option value="gpt-3.5-turbo-16k-0613">
                gpt-3.5-turbo-16k-0613
              </option>
            </select>
          </label>
        </div>
        <div className="form-area user-form">
          <label>
            チャット内容:
            <textarea
              className="text-area"
              placeholder="チャット内容を入力してね。"
              name="user_text"
              value={formState.user_text}
              onChange={handleInputChange}
            ></textarea>
          </label>
          <input
            type="submit"
            value="送信"
            style={{
              width: "width: 100%",
            }}
          />
        </div>
      </div>
    </form>
  );
};

export default ChatForm;
