require 'rails_helper'

feature 'Officing Nvotes', :selenium do
  let(:officer) { create(:poll_officer) }

  background do
    validate_officer
    login_as(officer.user)
    create(:geozone, census_code: "01")
  end

  scenario "Voting single poll" do
    user = create(:user, :in_census, id: rand(9999))
    poll = create(:poll)

    visit new_officing_residence_path
    officing_verify_residence

    click_link "Vote on tablet"

    nvotes = find(".agoravoting-voting-booth-iframe")
    within_frame(nvotes) do
      expect(page).to have_content "¿Quieres que XYZ sea aprobado?"

      first(".opt.ng-binding").click

      click_button "Continuar"

      expect(page).to have_content "La opción que seleccionaste es: Sí"
      click_button "Enviar el voto"

      expect(page).to have_content "Voto emitido con éxito"
    end

    expect(Poll::Nvote.count).to eq(1)
    nvote = Poll::Nvote.last

    expect(nvote.poll_id).to eq(poll.id)
    expect(nvote.user_id).to eq(user.id)
    expect(nvote.nvotes_poll_id).to eq(poll.nvotes_poll_id)
  end

  scenario "Voting all answerable polls" do
    user  = create(:user, :in_census, id: rand(9999))
    poll1 = create(:poll, nvotes_poll_id: 128, name: "¿Quieres que XYZ sea aprobado?")
    poll2 = create(:poll, nvotes_poll_id: 136, name: "Pregunta de votación de prueba")

    visit new_officing_residence_path
    officing_verify_residence

    click_link "Vote on tablet"

    nvotes = find(".agoravoting-voting-booth-iframe")
    within_frame(nvotes) do
      vote_for_poll(poll1)
    end

    within("#nvotes-sidebar") do
      click_link poll2.name
    end

    nvotes = find(".agoravoting-voting-booth-iframe")
    within_frame(nvotes) do
      vote_for_poll(poll2)
    end

    expect(Poll::Nvote.count).to eq(2)
    nvote_1 = Poll::Nvote.first
    expect(nvote_1.poll_id).to eq(poll1.id)
    expect(nvote_1.user_id).to eq(user.id)

    nvote_2 = Poll::Nvote.last
    expect(nvote_2.poll_id).to eq(poll2.id)
    expect(nvote_2.user_id).to eq(user.id)
  end

  scenario "Validate next document" do
    user  = create(:user, :in_census, id: rand(9999))
    poll = create(:poll)

    visit new_officing_residence_path
    officing_verify_residence

    click_link "Vote on tablet"

    nvotes = find(".agoravoting-voting-booth-iframe")
    within_frame(nvotes) do
      expect(page).to have_content "¿Quieres que XYZ sea aprobado?"
    end

    click_link "Finish voting"
    expect(page).to have_content "Thank you very much for your participation!"

    within("#nvotes-main") do
      click_link "Finish voting"
    end
    expect(page).to have_content "please give the device to the Officer"

    fill_in "officer_password", with: "judgmentday"
    click_button "Enter"

    expect(page).to have_content "Validate document"
  end

  scenario "Error on validate next document" do
    user  = create(:user, :in_census, id: rand(9999))
    poll = create(:poll)

    visit new_officing_residence_path
    officing_verify_residence

    click_link "Vote on tablet"

    nvotes = find(".agoravoting-voting-booth-iframe")
    within_frame(nvotes) do
      expect(page).to have_content "¿Quieres que XYZ sea aprobado?"
    end

    click_link "Finish voting"
    within("#nvotes-main") do
      click_link "Finish voting"
    end

    fill_in "officer_password", with: "not my password"
    click_button "Enter"

    expect(page).to have_content "Wrong password"
    expect(page).to have_content "please give the device to the Officer"
  end

  scenario "Trying to access unauthorized urls as a voter" do
    user  = create(:user, :in_census, id: rand(9999))
    poll = create(:poll)

    visit new_officing_residence_path
    officing_verify_residence

    click_link "Vote on tablet"

    nvotes = find(".agoravoting-voting-booth-iframe")
    within_frame(nvotes) do
      expect(page).to have_content "¿Quieres que XYZ sea aprobado?"
    end

    visit officing_root_path
    expect(page).to have_content "please give the device to the Officer"
  end

  scenario "Trying to access the officing nvote page as a non poll voter" do
    user = create(:user, :level_two)
    poll = create(:poll)

    login_as(user)
    visit new_officing_poll_nvote_path(poll)

    expect(page).to have_content "You do not have permission to carry out the action 'new' on poll/nvote"
  end

end
