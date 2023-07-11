import { useState } from "react";
import axios from "axios";

const ChatForm = ({ chatHistory, setChatHistory }) => {
  const [formState, setFormState] = useState({
    system_text: "",
    user_text: "",
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
    };

    axios
      .get(url, { params })
      .then((response) => {
        console.log(response);
        // システムのメッセージをチャットの履歴に追加
        setChatHistory((prevChatHistory) => [
          ...prevChatHistory,
          { message: response.data, type: "system" },
        ]);
      })
      .catch((error) => {
        console.log(url, { params });
        console.error("Error:", error);
      });
  };

  return (
    <form
      onSubmit={handleSubmit}
      style={{
        position: "fixed",
        bottom: "0",
        width: "100%",
        display: "flex",
        flexDirection: "column",
        justifyContent: "center",
        alignItems: "center",
        backgroundColor: "#fff",
        padding: "20px",
        borderTop: "1px solid #ccc",
      }}
    >
      <div
        style={{
          display: "flex",
          flexDirection: "row",
          alignItems: "center",
        }}
      >
        <label style={{ marginRight: "10px" }}>
          システムテキスト:
          <input
            type="text"
            name="system_text"
            value={formState.system_text}
            onChange={handleInputChange}
          />
        </label>
        <input type="submit" value="送信" />
      </div>
      <label>
        ユーザーテキスト:
        <input
          type="text"
          name="user_text"
          value={formState.user_text}
          onChange={handleInputChange}
        />
      </label>
    </form>
  );
};

export default ChatForm;
