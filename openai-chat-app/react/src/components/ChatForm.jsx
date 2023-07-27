import { useState } from "react";
import useChatApi from "./useChatApi";

const ChatForm = ({ chatHistory, setChatHistory }) => {
  const [formState, setFormState] = useState({
    system_text: "",
    user_text: "",
    api_model: "gpt-3.5-turbo",
  });

  const { fetchChatResponse } = useChatApi(); // 使用

  const handleInputChange = (event) => {
    setFormState({
      ...formState,
      [event.target.name]: event.target.value,
    });
  };

  // OpenAIチャット処理
  const handleSubmit = (event) => {
    event.preventDefault();
    if (formState.user_text === "") return;

    // ユーザーのメッセージをチャットの履歴に追加
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

    // user_textとsystem_textを空にリセット
    setFormState({
      ...formState,
      user_text: "",
      system_text: "",
    });
    // レスポンスをメッセージ履歴に追加
    fetchChatResponse(url, params, (sanitizedMessage) => {
      setChatHistory((prevChatHistory) => [
        ...prevChatHistory,
        { message: sanitizedMessage, type: "system" },
      ]);
    });
  };

  // 履歴削除処理
  const handleDelete = (event) => {
    event.preventDefault();
    const isConfirmed = window.confirm("本当に履歓を削除しますか？");
    if (!isConfirmed) {
      // ユーザーがキャンセルを選択した場合、処理を中止
      return;
    }

    // CloudFront ディストリビューションドメイン名
    const url = import.meta.env.VITE_LAMBDA_URL;
    const params = {
      delete: "True",
    };

    fetchChatResponse(url, params, () => {
      // 履歴を削除
      setChatHistory([]);
    });

    // user_textとsystem_textを空にリセット
    setFormState({
      ...formState,
      user_text: "",
      system_text: "",
    });
  };

  return (
    <>
      <div className="top-form">
        <form onSubmit={handleDelete}>
          <input
            type="submit"
            value="チャット履歴削除"
            className="delete-btn"
          />
        </form>
        <select
          name="api_model"
          className="api-model-select"
          value={formState.api_model}
          onChange={handleInputChange}
        >
          <option value="gpt-3.5-turbo">gpt-3.5-turbo</option>
          <option value="gpt-3.5-turbo-16k">gpt-3.5-turbo-16k</option>
          <option value="gpt-3.5-turbo-0613">gpt-3.5-turbo-0613</option>
          <option value="gpt-3.5-turbo-16k-0613">gpt-3.5-turbo-16k-0613</option>
        </select>
      </div>
      <form onSubmit={handleSubmit} className="bottom-form">
        <div className="form-wrap">
          <div className="form-area system-form">
            <label style={{ marginRight: "10px" }}>
              AIの役割/性格
              <textarea
                placeholder="AIの役割とか性格を入力してね。"
                name="system_text"
                value={formState.system_text}
                onChange={handleInputChange}
                className="text-area"
              ></textarea>
            </label>
          </div>
          <div className="form-area user-form">
            <label>
              チャット内容
              <textarea
                className="text-area"
                placeholder="チャット内容を入力してね。"
                name="user_text"
                value={formState.user_text}
                onChange={handleInputChange}
              ></textarea>
            </label>
            <input
              className="submit-btn"
              type="submit"
              value="送信"
              style={{
                width: "width: 100%",
              }}
            />
          </div>
        </div>
      </form>
    </>
  );
};

export default ChatForm;
